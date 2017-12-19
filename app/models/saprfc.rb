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

    pack_items = function.getTableParameterList().getTable('PACK_ITEMS')
    hash = {}
    (0..pack_items.getNumRows - 1).each do |i|
      #puts "#{i} #{pack_items.getString('POSNR')} #{pack_items.getInt('PMQTY')} #{pack_items.getString('PMQTP')}"
      hash[pack_items.getString('POSNR')] = 0 if hash[pack_items.getString('POSNR')].nil?
      hash["#{pack_items.getString('POSNR')}_P"] = 0 if hash["#{pack_items.getString('POSNR')}_P"].nil?
      hash[pack_items.getString('POSNR')] += pack_items.getInt('2M2QY') if pack_items.getString('PMBQT').upcase.include?('BOX')
      hash["#{pack_items.getString('POSNR')}_P"] += pack_items.getInt('PMQTY')

      hash["#{pack_items.getString('POSNR')}_GW"] = 0.0 if hash["#{pack_items.getString('POSNR')}_GW"].nil?
      hash["#{pack_items.getString('POSNR')}_GW"] += pack_items.getDouble('TGWEG')

      pack_items.nextRow
    end
    com.sap.conn.jco.JCoContext.end(dest)
    hash
  end

  def self.get_read_text(text_lines_table_json)
    dest = JCoDestinationManager.getDestination('sap_prd')
    repos = dest.getRepository
    function = repos.getFunction('RFC_READ_TEXT')
    lines = function.getTableParameterList().getTable('TEXT_LINES')
    rows = JSON.parse(text_lines_table_json)
    rows.each do |row|
      lines.appendRow()
      lines.setValue('MANDT', row['mandt'])
      lines.setValue('TDOBJECT', row['tdobject'])
      lines.setValue('TDNAME', row['tdname'])
      lines.setValue('TDID', row['tdid'])
      lines.setValue('TDSPRAS', row['tdspras'])
    end
    com.sap.conn.jco.JCoContext.begin(dest)
    function.execute(dest)
    table = []
    text_lines = function.getTableParameterList().getTable('TEXT_LINES')
    (0..text_lines.getNumRows - 1).each do |i|
      table.append({mandt: text_lines.getString('MANDT'),
                    tdobject: text_lines.getString('TDOBJECT'),
                    tdname: text_lines.getString('TDNAME'),
                    tdid: text_lines.getString('TDID'),
                    tdspras: text_lines.getString('TDSPRAS'),
                    tdline: text_lines.getString('TDLINE')})
      text_lines.nextRow
    end
    com.sap.conn.jco.JCoContext.end(dest)
    table
  end

  def self.remove_sto_conf_ctrl
    sql = "
        select a.ebeln,a.ebelp,a.bstae
        from sapsr3.ekpo a
          join sapsr3.ekko b on b.mandt=a.mandt and b.ebeln=a.ebeln and b.reswk <> ' '
        where a.mandt='168' and a.elikz=' ' and a.loekz=' ' and a.matnr <> ' ' and a.menge > 0 and bstae <> ' '
    "
    Sapdb.find_by_sql(sql).each do |row|
      dest  = JCoDestinationManager.getDestination('sap_prd')
      repos = dest.getRepository

      commit = repos.getFunction('BAPI_TRANSACTION_COMMIT')
      commit.getImportParameterList.setValue('WAIT', 'X')

      function = repos.getFunction('BAPI_PO_CHANGE')
      function.getImportParameterList.setValue('PURCHASEORDER', row.ebeln)

      poItem = function.getTableParameterList().getTable('POITEM')
      poItem.appendRow()
      poItem.setValue('PO_ITEM', row.ebelp)
      poItem.setValue('CONF_CTRL', ' ')

      poItemx = function.getTableParameterList().getTable('POITEMX')
      poItemx.appendRow();
      poItemx.setValue('PO_ITEM', row.ebelp)
      poItemx.setValue('CONF_CTRL', 'X')

      com.sap.conn.jco.JCoContext.begin(dest)
      function.execute(dest)
      commit.execute(dest)
      com.sap.conn.jco.JCoContext.end(dest)

      returnMessage = function.getTableParameterList().getTable('RETURN')
      (1..returnMessage.getNumRows).each { |i|
        puts "#{i}: PO: #{row.ebeln}.#{row.ebelp} Type:#{returnMessage.getString('TYPE')}, MSG:#{returnMessage.getString('MESSAGE')}"
        returnMessage.nextRow
      }
    end
  end

  def self.set_ekpo_elikz
    sql = "
      select ebeln,ebelp from (
        select a.ebeln,a.ebelp,a.menge ekpo_menge,
               (select sum(x.wemng) from sapsr3.eket x where x.mandt=a.mandt and x.ebeln=a.ebeln and x.ebelp=a.ebelp) eket_wemng
          from sapsr3.ekpo a
            join sapsr3.ekko b on b.mandt=a.mandt and b.ebeln=a.ebeln and b.reswk=' '
          where a.mandt='168' and a.elikz=' ' and a.loekz=' ' and a.matnr <> ' ' and a.menge > 0)
        where ekpo_menge <= eket_wemng
    "
    list = Sapdb.find_by_sql(sql)
    list.each do |row|
      dest  = JCoDestinationManager.getDestination('sap_prd')
      repos = dest.getRepository

      commit = repos.getFunction('BAPI_TRANSACTION_COMMIT')
      commit.getImportParameterList.setValue('WAIT', 'X')

      function = repos.getFunction('BAPI_PO_CHANGE')
      function.getImportParameterList.setValue('PURCHASEORDER', row.ebeln)

      poItem = function.getTableParameterList().getTable('POITEM')
      poItem.appendRow()
      poItem.setValue('PO_ITEM', row.ebelp)
      poItem.setValue('NO_MORE_GR', 'X')

      poItemx = function.getTableParameterList().getTable('POITEMX')
      poItemx.appendRow();
      poItemx.setValue('PO_ITEM', row.ebelp)
      poItemx.setValue('NO_MORE_GR', 'X')

      com.sap.conn.jco.JCoContext.begin(dest)
      function.execute(dest)
      commit.execute(dest)
      com.sap.conn.jco.JCoContext.end(dest)

      returnMessage = function.getTableParameterList().getTable('RETURN')
      (1..returnMessage.getNumRows).each { |i|
        puts "#{i}: PO: #{row.ebeln}.#{row.ebelp} Type:#{returnMessage.getString('TYPE')}, MSG:#{returnMessage.getString('MESSAGE')}"
        returnMessage.nextRow
      }
    end
  end

  def self.change_po_delivery_date
    sql = "
      select delnr,delps,delet,umdat,dat01,aussl from sapsr3.zsd0012
        where mandt='168' and werks in ('111A','112A') and delkz='BE' and  aussl in ('U1','U2') and lifnr='L210-PH'
    "
    list = Sapdb.find_by_sql(sql)
    list.each do |row|
      dest  = JCoDestinationManager.getDestination('sap_prd')
      repos = dest.getRepository

      commit = repos.getFunction('BAPI_TRANSACTION_COMMIT')
      commit.getImportParameterList.setValue('WAIT', 'X')

      function = repos.getFunction('BAPI_PO_CHANGE')
      function.getImportParameterList.setValue('PURCHASEORDER', row.delnr)


      impDat = function.getTableParameterList().getTable("POSCHEDULE")
      impDat.appendRow()
      impDat.setValue("PO_ITEM", row.delps)
      impDat.setValue("SCHED_LINE", row.delet)
      impDat.setValue("DELIVERY_DATE", row.umdat)
      impDat.setValue("DEL_DATCAT_EXT", "D")

      impDatx = function.getTableParameterList().getTable("POSCHEDULEX")
      impDatx.appendRow();
      impDatx.setValue("PO_ITEM", row.delps)
      impDatx.setValue("PO_ITEMX", "X")
      impDatx.setValue("SCHED_LINE", row.delet)
      impDatx.setValue("SCHED_LINEX", "X")
      impDatx.setValue("DELIVERY_DATE", "X")
      impDatx.setValue("DEL_DATCAT_EXT", "X")

      com.sap.conn.jco.JCoContext.begin(dest)
      function.execute(dest)
      commit.execute(dest)
      com.sap.conn.jco.JCoContext.end(dest)

      returnMessage = function.getTableParameterList().getTable('RETURN')
      (1..returnMessage.getNumRows).each { |i|
        puts "#{i}: PO: #{row.delnr}.#{row.delet} Type:#{returnMessage.getString('TYPE')}, MSG:#{returnMessage.getString('MESSAGE')}"
        returnMessage.nextRow
      }
    end
  end

end