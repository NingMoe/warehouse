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
    dest  = JCoDestinationManager.getDestination('sap_prd')
    repos = dest.getRepository

    commit = repos.getFunction('BAPI_TRANSACTION_COMMIT')
    commit.getImportParameterList().setValue('WAIT', 'X')

    function = repos.getFunction('BAPI_REQUISITION_CREATE')
    function.getImportParameterList.setValue('SKIP_ITEMS_WITH_ERROR', ' ')
    function.getImportParameterList.setValue('AUTOMATIC_SOURCE', 'X')

    item_data = function.getTableParameterList.getTable('REQUISITION_ITEMS')

    sql  = "
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
end