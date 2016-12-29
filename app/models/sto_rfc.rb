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
    #sql = "select * from sto where status='10WaitDnCreate' and rfc_msg_type is null"
    sql = "
      with
        tsto as (
          select /*+ materialize */ werks_from, matnr, sum(menge) menge
            from sto
            where status='10WaitDnCreate' and rfc_msg_type is null
            group by werks_from, matnr),
        tiss as (
          select /*+ materialize */ werks_from, matnr, sum(menge) menge
            from sto
            where status='20WaitDNIssue'  and rfc_msg_type is null
            group by werks_from, matnr),
        tmard as (
          select /*+ materialize +driving_site(a)*/
            a.werks,a.matnr,sum(a.labst) labst
            from sapsr3.mard@sapp a
            where a.mandt='168' and (a.werks,a.matnr) in (select werks_from, matnr from tsto)
            group by a.werks,a.matnr)
        select c.*
          from tsto a
            join tmard b on b.werks=a.werks_from and b.matnr=a.matnr
            join sto c on c.werks_from=a.werks_from and c.matnr=a.matnr
                      and c.status='10WaitDnCreate' and c.rfc_msg_type is null
            left join tiss d on d.werks_from=a.werks_from and d.matnr=a.matnr
          where b.labst >= (a.menge + nvl(d.menge,0))
    "
    dlv_notes = Sto.find_by_sql(sql)
    dlv_notes.each do |dlv_note|
      begin
        dest = JCoDestinationManager.getDestination('sap_prd')
        repos = dest.getRepository
        commit = repos.getFunction('BAPI_TRANSACTION_COMMIT')
        commit.getImportParameterList().setValue('WAIT', 'X')

        function = repos.getFunction('BAPI_OUTB_DELIVERY_CREATE_STO')
        function.getImportParameterList().setValue('SHIP_POINT', dlv_note.werks_from)

        lines = function.getTableParameterList().getTable('STOCK_TRANS_ITEMS')

        stos = Sto.where(uuid: dlv_note.id)

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
        posting_success = return_message(dlv_note.rfc_batch_id, returnMessage)

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
        posting_success = return_message(dlv_note.rfc_batch_id, returnMessage)

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

  def self.return_message(rfc_batch_id, returnMessage)
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

  def self.insert_po_receipt
    uuids = []
    sql = "
      select /*+DRIVING_SITE(b)*/
          a.werks_to,a.lifnr,a.vbeln,a.matnr,a.impnr,a.impim,a.ebeln,a.ebelp,
          b.charg,b.lfimg,c.invnr,d.hsdat,a.uuid,e.dpseq,a.remote_ip,a.creator,
          f.meins,f.netpr,f.peinh
        from sto a
          join sapsr3.lips@sapp b on b.mandt='168' and b.vbeln=a.vbeln and b.lfimg > 0
          join sapsr3.mch1@sapp d on d.mandt='168' and d.matnr=b.matnr and d.charg=b.charg
          join sapsr3.ekpo@sapp f on f.mandt='168' and f.ebeln=a.ebeln and f.ebelp=a.ebelp
          left join sapsr3.ziebi002@sapp c on c.mandt='168' and c.impnr=a.impnr and c.impim=a.impim
          left join sapsr3.ziebi001@sapp e on e.mandt='168' and e.impnr=a.impnr
        where a.po_receipt_id is null and a.status='30WaitBilling'
    "
    rows = Sto.find_by_sql(sql)
    i = 0
    begin
      Sto.transaction do
        rows.each do |row|
          uuids.append(row.uuid) unless uuids.include?(row.uuid)
          i = i + 1
          lifdn = row.invnr.present? ? row.invnr : row.vbeln
          po_receipt = PoReceipt.create(
              uuid: UUID.new.generate(:compact),
              barcode: "@#{row.matnr}@#{row.werks_to}@#{row.lifnr}@#{lifdn}@#{row.charg}@#{row.hsdat}@#{row.lfimg}@#{i}@#{Time.now.strftime('%Y%m%d%H%M%S')}",
              vtweg: PoReceipt.vtweg(row.werks_to),
              lifnr: row.lifnr,
              lifdn: lifdn,
              matnr: row.matnr,
              werks: row.werks_to,
              pkg_no: i,
              date_code: row.charg,
              mfg_date: row.hsdat,
              entry_date: Time.now.strftime('%Y%m%d'),
              menge: row.lfimg,
              alloc_qty: row.lfimg,
              balqty: 0,
              status: '20',
              vtype: 'V1',
              impnr: row.impnr,
              charg: row.charg,
              remote_ip: row.remote_ip,
              creator: row.creator,
              updater: row.creator,
              dpseq: row.dpseq,
              vbeln: row.vbeln
          )

          PoReceiptLine.create(
              uuid: UUID.new.generate(:compact),
              po_receipt_id: po_receipt.uuid,
              status: '20',
              impnr: row.impnr,
              impim: row.impim,
              invnr: lifdn,
              ebeln: row.ebeln,
              ebelp: row.ebelp,
              netpr: row.netpr,
              peinh: row.peinh,
              alloc_qty: row.lfimg,
              menge: 0,
              meins: row.meins,
              charg: row.charg,
              creator: row.creator,
              updater: row.creator
          )
        end
        Sto.where(uuid: uuids).update_all(po_receipt_id: 'X')
      end
    rescue
    end
  end
end