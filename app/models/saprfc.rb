class Saprfc
  require 'java'
  java_import 'java.io.File'
  java_import 'java.io.FileOutputStream'
  java_import 'java.util.Properties'
  java_import 'com.sap.conn.jco.JCoDestination'
  java_import 'com.sap.conn.jco.JCoDestinationManager'
  java_import 'com.sap.conn.jco.ext.DestinationDataEventListener'
  java_import 'com.sap.conn.jco.ext.DestinationDataProvider'
  java_import 'com.sap.conn.jco.JCoContext'

  def self.dn_pack_qty(vbeln)
    dest = JCoDestinationManager.getDestination('sap_prd')
    repos = dest.getRepository
    function = repos.getFunction('Z_SD_PACKING_SHIPPING_DATA')
    function.getImportParameterList().setValue('VBELN', vbeln)
    function.getImportParameterList().setValue('PRDDN', 'X')
    function.getImportParameterList().setValue('RMRPO', ' ')
    function.getImportParameterList().setValue('PICDO', ' ')
    function.getImportParameterList().setValue('EBELN', ' ')
    function.getImportParameterList().setValue('PRTCA', 'X')
    com.sap.conn.jco.JCoContext.begin(dest)
    function.execute(dest)
    com.sap.conn.jco.JCoContext.end(dest)
    pack_items = function.getTableParameterList().getTable('PACK_ITEMS')
    hash = {}
    (1..pack_items.getNumRows).each do |i|
      hash[pack_items.getString('POSNR')] = 0 if hash[pack_items.getString('POSNR')].nil?
      hash[pack_items.getString('POSNR')] += pack_items.getString('TOCAN').to_i
      pack_items.nextRow
    end
    hash
  end

end