class StoRfc
  require 'java'
  java_import 'java.io.File'
  java_import 'java.io.FileOutputStream'
  java_import 'java.util.Properties'
  java_import 'com.sap.conn.jco.JCoDestination'
  java_import 'com.sap.conn.jco.JCoDestinationManager'
  java_import 'com.sap.conn.jco.ext.DestinationDataEventListener'
  java_import 'com.sap.conn.jco.ext.DestinationDataProvider'
  java_import 'com.sap.conn.jco.JCoContext'

  def self.create_sap_dn
    sql = "select distinct rfc_batch_id,ebeln from sto where status='10WaitDnCreate' and rfc_msg_type is null"
    dlv_notes = Sto.find_by_sql(sql)
    dlv_notes.each do |dlv_note|
      begin
        dest = JCoDestinationManager.getDestination('sap_prd')
        repos = dest.getRepository
        commit = repos.getFunction('BAPI_TRANSACTION_COMMIT')
        commit.getImportParameterList().setValue('WAIT', 'X')

        function = repos.getFunction('BAPI_OUTB_DELIVERY_CREATE_STO')
        function.getImportParameterList().setValue('SHIP_POINT',dlv_note.werks_from)

        lines = function.getTableParameterList().getTable('STOCK_TRANS_ITEMS')

        stos = Sto.where(status: '10WaitDnCreate', rfc_batch_id: dlv_note.rfc_batch_id, ebeln: dlv_note.ebeln, rfc_msg_type: nil)

        dlv_note.rfc_batch_id = UUID.new.generate(:compact) if dlv_note.rfc_batch_id.blank?
        stos.each do |sto|
          lines.appendRow()
          lines.setValue('REF_DOC', sto.ebeln)
          lines.setValue('REF_ITEM', sto.ebelp)
          lines.setValue('DLV_QTY', sto.menge)
          lines.setValue('SALES_UNIT', sto.meins)
          sto.rfc_batch_id = dlv_note.rfc_batch_id if sto.rfc_batch_id
        end

        com.sap.conn.jco.JCoContext.begin(dest)
        function.execute(dest)

        posting_success = true
        returnMessage = function.getTableParameterList().getTable('RETURN')
        (1..returnMessage.getNumRows).each do |i|
          puts "#{i} Type:#{returnMessage.getString('TYPE')}, MSG:#{returnMessage.getString('MESSAGE')}"
          if returnMessage.getString('TYPE').eql?('E')
            posting_success = false
            RfcMsg.create(
                rfc_batch_id: dlv_note.rfc_batch_id,
                rfc_msg_type: returnMessage.getString('TYPE'),
                rfc_id: returnMessage.getString('ID'),
                rfc_number: returnMessage.getString('NUMBER'),
                rfc_message: returnMessage.getString('MESSAGE'),
                rfc_log_no: returnMessage.getString('LOG_NO'),
                rfc_log_msg_no: returnMessage.getString('LOG_MSG_NO'),
                rfc_message_v1: returnMessage.getString('MESSAGE_V1'),
                rfc_message_v2: returnMessage.getString('MESSAGE_V2'),
                rfc_message_v3: returnMessage.getString('MESSAGE_V3'),
                rfc_message_v4: returnMessage.getString('MESSAGE_V4'),
                rfc_parameter: returnMessage.getString('PARAMETER'),
                rfc_row: returnMessage.getString('ROW'),
                rfc_field: returnMessage.getString('FIELD'),
                rfc_system: returnMessage.getString('SYSTEM')
            )
          end
          returnMessage.nextRow
        end

        if posting_success
          vbeln = function.getExportParameterList().getValue('DELIVERY')
          stos.each do |sto|
            sto.vbeln = vbeln
            sto.rfc_msg_type = ''
            sto.status = '20WaitDNIssue'
            sto.save
          end
        else
          stos.each do |sto|
            sto.rfc_msg_type = 'E'
            sto.save
          end
        end

        commit.execute(dest)
        com.sap.conn.jco.JCoContext.end(dest)
      rescue Exception => exception
        puts exception
        Mail.defaults do
          delivery_method :smtp, address: '172.91.1.253', port: 25
        end
        message = "#{dlv_note.werks_from}, #{dlv_note.werks_to}, #{dlv_note.lifnr}"
        message = "#{message} #{exception.message} #{exception.backtrace.join('\n')}"

        Mail.deliver do
          from 'lum.cl@l-e-i.com'
          to 'lum.cl@l-e-i.com, ted.meng@l-e-i.com'
          subject 'warehouse.sto_rfc.create_sap_dn'
          body message
        end
      end
    end
  end

  def self.sap_dn_issue
    sql = "select distinct a.rfc_batch_id, a.vbeln from sto a where a.status='20WaitDNIssue' and rfc_msg_type is null order by a.vbeln"
    dlv_notes = Sto.find_by_sql(sql)
    dlv_notes.each do |dlv_note|
      begin
        dest = JCoDestinationManager.getDestination('sap_prd')
        repos = dest.getRepository
        commit = repos.getFunction('BAPI_TRANSACTION_COMMIT')
        commit.getImportParameterList().setValue('WAIT', 'X')

        function = repos.getFunction('BAPI_OUTB_DELIVERY_CONFIRM_DEC')
        header = function.getImportParameterList().getStructure('HEADER_DATA')
        header.setValue('DELIV_NUMB', dlv_note.vbeln)

        header_control = function.getImportParameterList().getStructure('HEADER_CONTROL')
        header_control.setValue('DELIV_NUMB', dlv_note.vbeln)
        header_control.setValue('POST_GI_FLG', 'X')

        function.getImportParameterList().setValue('DELIVERY', dlv_note.vbeln)

        com.sap.conn.jco.JCoContext.begin(dest)
        function.execute(dest)

        returnMessage = function.getTableParameterList().getTable('RETURN')
        posting_success = return_message(dlv_note.rfc_batch_id,returnMessage)

        if posting_success
          Sto.where(vbeln: dlv_note.vbeln).update_all(status: '30WaitBilling', rfc_msg_type: '')
        else
          Sto.where(vbeln: dlv_note.vbeln).update_all(rfc_msg_type: 'E')
        end

        commit.execute(dest)
        com.sap.conn.jco.JCoContext.end(dest)
      rescue Exception => exception
        puts exception
        Mail.defaults do
          delivery_method :smtp, address: '172.91.1.253', port: 25
        end
        message = "#{dlv_note.vbeln}, #{dlv_note.rfc_batch_id}"
        message = "#{message} #{exception.message} #{exception.backtrace.join('\n')}"

        Mail.deliver do
          from 'lum.cl@l-e-i.com'
          to 'lum.cl@l-e-i.com, ted.meng@l-e-i.com'
          subject 'warehouse.sto_rfc.sap_dn_issue'
          body message
        end
      end
    end
  end

  def self.sap_billing
    sql = "select distinct a.rfc_batch_id, a.vbeln from sto a where a.status='30WaitBilling' and rfc_msg_type is null order by a.vbeln"
    dlv_notes = Sto.find_by_sql(sql)
    dlv_notes.each do |dlv_note|
      begin
        dest = JCoDestinationManager.getDestination('sap_prd')
        repos = dest.getRepository
        commit = repos.getFunction('BAPI_TRANSACTION_COMMIT')
        commit.getImportParameterList().setValue('WAIT', 'X')

        function = repos.getFunction('BAPI_BILLINGDOC_CREATEMULTIPLE')

        lines = function.getTableParameterList().getTable('BILLINGDATAIN')
        lines.appendRow()
        lines.setValue('REF_DOC', dlv_note.vbeln)
        lines.setValue('REF_DOC_CA', 'J')

        com.sap.conn.jco.JCoContext.begin(dest)
        function.execute(dest)

        returnMessage = function.getTableParameterList().getTable('RETURN')
        posting_success = return_message(dlv_note.rfc_batch_id,returnMessage)

        if posting_success
          Sto.where(vbeln: dlv_note.vbeln).update_all(status: '40WaitGoodsReceived', rfc_msg_type: '')
        else
          Sto.where(vbeln: dlv_note.vbeln).update_all(rfc_msg_type: 'E')
        end

        commit.execute(dest)
        com.sap.conn.jco.JCoContext.end(dest)

      rescue Exception => exception
        puts exception
        Mail.defaults do
          delivery_method :smtp, address: '172.91.1.253', port: 25
        end
        message = "#{dlv_note.vbeln}, #{dlv_note.rfc_batch_id}"
        message = "#{message} #{exception.message} #{exception.backtrace.join('\n')}"

        Mail.deliver do
          from 'lum.cl@l-e-i.com'
          to 'lum.cl@l-e-i.com, ted.meng@l-e-i.com'
          subject 'warehouse.sto_rfc.sap_billing'
          body message
        end

      end
    end
  end

  def self.return_message(rfc_batch_id,returnMessage)
    posting_success = true
    (1..returnMessage.getNumRows).each do |i|
      puts "#{i} Type:#{returnMessage.getString('TYPE')}, MSG:#{returnMessage.getString('MESSAGE')}"
      if returnMessage.getString('TYPE').eql?('E')
        posting_success = false
        RfcMsg.create(
            rfc_batch_id: rfc_batch_id,
            rfc_msg_type: returnMessage.getString('TYPE'),
            rfc_id: returnMessage.getString('ID'),
            rfc_number: returnMessage.getString('NUMBER'),
            rfc_message: returnMessage.getString('MESSAGE'),
            rfc_log_no: returnMessage.getString('LOG_NO'),
            rfc_log_msg_no: returnMessage.getString('LOG_MSG_NO'),
            rfc_message_v1: returnMessage.getString('MESSAGE_V1'),
            rfc_message_v2: returnMessage.getString('MESSAGE_V2'),
            rfc_message_v3: returnMessage.getString('MESSAGE_V3'),
            rfc_message_v4: returnMessage.getString('MESSAGE_V4')
            # rfc_parameter: returnMessage.getString('PARAMETER'),
            # rfc_row: returnMessage.getString('ROW'),
            # rfc_field: returnMessage.getString('FIELD'),
            # rfc_system: returnMessage.getString('SYSTEM')
        )
      end
      returnMessage.nextRow
    end
    posting_success
  end

end