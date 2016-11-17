class PhSto
  require 'java'
  java_import 'java.io.File'
  java_import 'java.io.FileOutputStream'
  java_import 'java.util.Properties'
  java_import 'com.sap.conn.jco.JCoDestination'
  java_import 'com.sap.conn.jco.JCoDestinationManager'
  java_import 'com.sap.conn.jco.ext.DestinationDataEventListener'
  java_import 'com.sap.conn.jco.ext.DestinationDataProvider'
  java_import 'com.sap.conn.jco.JCoContext'

  def self.create_pr(ebeln)
    dest = JCoDestinationManager.getDestination('sap_prd')
    repos = dest.getRepository

    commit = repos.getFunction('BAPI_TRANSACTION_COMMIT')
    commit.getImportParameterList().setValue('WAIT', 'X')

    function = repos.getFunction('BAPI_REQUISITION_CREATE')
    function.getImportParameterList.setValue('SKIP_ITEMS_WITH_ERROR', ' ')
    function.getImportParameterList.setValue('AUTOMATIC_SOURCE', 'X')

    item_data = function.getTableParameterList.getTable('REQUISITION_ITEMS')

    sql = "
      select a.ebeln,a.ebelp,a.matnr,b.menge,a.meins,
             b.eindt
        from sapsr3.ekpo a
          join sapsr3.eket b on b.mandt='168' and b.ebeln=a.ebeln and b.ebelp=a.ebelp and b.menge <> 0
        where a.mandt='168' and a.ebeln='#{ebeln}'
    "
    list = Sapdb.find_by_sql(sql)
    list.each do |row|
      item_data.appendRow
      item_data.setValue('DOC_TYPE', 'Z001')
      item_data.setValue('PREQ_ITEM', row.ebelp)
      item_data.setValue('PREQ_NAME', row.ebelp)
      item_data.setValue('MATERIAL', row.matnr)
      item_data.setValue('PLANT', '281A')
      item_data.setValue('STORE_LOC', 'PH01')
      item_data.setValue('TRACKINGNO', row.ebeln)
      item_data.setValue('QUANTITY', row.menge)
      item_data.setValue('UNIT', row.meins)
      item_data.setValue('DELIV_DATE', row.eindt)
    end

    com.sap.conn.jco.JCoContext.begin(dest)
    function.execute(dest)
    commit.execute(dest)
    com.sap.conn.jco.JCoContext.end(dest)

    returnMessage = function.getTableParameterList().getTable("RETURN")
    (1..returnMessage.getNumRows).each { |i|
      puts "#{i} Type:#{returnMessage.getString('TYPE')}, MSG:#{returnMessage.getString('MESSAGE')}, BANF:#{returnMessage.getString('MESSAGE_V1')}"
      returnMessage.nextRow
    }

  end

  def self.create_po_agreement
    begin
      dest = JCoDestinationManager.getDestination('sap_prd')
      repos = dest.getRepository
      commit = repos.getFunction('BAPI_TRANSACTION_COMMIT')
      commit.getImportParameterList().setValue('WAIT', 'X')

      function = repos.getFunction('BAPI_SAG_CREATE')

      header = function.getImportParameterList().getStructure('HEADER')
      header.setValue('COMP_CODE', 'L111')
      header.setValue('DOC_TYPE', 'ZLP')
      header.setValue('ITEM_INTVL', '00010')
      header.setValue('VENDOR', 'L210-Y')
      header.setValue('PURCH_ORG', 'L111')
      header.setValue('PUR_GROUP', '013')
      header.setValue('CURRENCY', 'RMB')
      header.setValue('VPER_START', '20161112')
      header.setValue('VPER_END', '20191112')
      header.setValue('SUPPL_PLNT', '281A')

      com.sap.conn.jco.JCoContext.begin(dest)
      function.execute(dest)

      returnMessage = function.getTableParameterList().getTable('RETURN')
      (1..returnMessage.getNumRows).each do |i|
        puts "#{i} Type:#{returnMessage.getString('TYPE')}, MSG:#{returnMessage.getString('MESSAGE')}"
        RfcMsg.create(
            rfc_batch_id: 'LUM',
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
        returnMessage.nextRow
      end

      commit.execute(dest)
      com.sap.conn.jco.JCoContext.end(dest)
    rescue Exception => exception
      puts exception
      Mail.defaults do
        delivery_method :smtp, address: '172.91.1.253', port: 25
      end
      message = "#{message} #{exception.message} #{exception.backtrace.join('\n')}"

      Mail.deliver do
        from 'lum.cl@l-e-i.com'
        to 'lum.cl@l-e-i.com'
        subject 'warehouse.sto_rfc.create_po_agreement'
        body message
      end
    end
  end

end