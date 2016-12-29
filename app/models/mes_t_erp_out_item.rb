class MesTErpOutItem < ActiveRecord::Base
  self.table_name = :t_erp_out_items
  establish_connection :leimes
  attr_accessor :ws_alloc_qty

  require 'java'
  java_import 'java.io.File'
  java_import 'java.io.FileOutputStream'
  java_import 'java.util.Properties'
  java_import 'com.sap.conn.jco.JCoDestination'
  java_import 'com.sap.conn.jco.JCoDestinationManager'
  java_import 'com.sap.conn.jco.ext.DestinationDataEventListener'
  java_import 'com.sap.conn.jco.ext.DestinationDataProvider'
  java_import 'com.sap.conn.jco.JCoContext'

  def self.to_mes_location
    sql = "select distinct plant from t_erp_out_items where status = ' ' order by plant"
    rows = MesTErpOutItem.find_by_sql(sql)
    rows.each do |row|
      compute(row.plant)
    end
  end

  def self.compute(werks)
    while true do
      sql = "select distinct plant,item_code,lot_no from t_erp_out_items where status = ' ' and plant = ? and rownum < 500"
      rows = MesTErpOutItem.find_by_sql([sql, werks])
      break if rows.blank?
      mat_lot_refs = []
      rows.each do |row|
        mat_lot_refs.append("('#{row.plant}','#{row.item_code}','#{row.lot_no}')")
      end

      sql = "
          select matnr,werks,lgort,charg,clabs from sapsr3.mchb
          where mandt='168' and (werks,matnr,charg) in (#{mat_lot_refs.join(',')}) and clabs > 0
        "
      mchbs = {}
      rows = Sapdb.find_by_sql(sql)
      rows.each do |row|
        key = "#{row.werks}.#{row.matnr}.#{row.charg}"
        mchbs[key] = [] unless mchbs.key?(key)
        mchbs[key].append(row)
      end

      msegs = []
      mes_t_erp_out_items = MesTErpOutItem.where(status: ' ').where("(plant,item_code,lot_no) in (#{mat_lot_refs.join(',')})")
      mes_t_erp_out_items.each do |row|
        row.ws_alloc_qty = 0
        req_qty = row.item_num - row.trf_qty
        if req_qty > 0
          key = "#{row.plant}.#{row.item_code}.#{row.lot_no}"
          if mchbs.key?(key)
            mchbs[key].each do |mchb|
              if mchb.clabs > 0
                ws_qty = mchb.clabs > req_qty ? req_qty : mchb.clabs
                mchb.clabs -= ws_qty
                row.trf_qty += ws_qty
                row.ws_alloc_qty += ws_qty
                req_qty -= ws_qty
                msegs.append({werks: mchb.werks, matnr: mchb.matnr, lgort: mchb.lgort, charg: mchb.charg, menge: ws_qty, aufnr: row.project_id[0..49]})
              end
              break if req_qty == 0
            end
          end
        end
      end
      puts "#######"
      msegs.each do |mseg|
        puts mseg
      end
      break
      # posting_success = bapi_goodsmvt_create_311(msegs)
      # mes_t_erp_out_items.each do |row|
      #   if posting_success
      #     row.row.status = row.trf_qty == item_num ?  'X' :  'W'
      #   else
      #     row.status = 'E'
      #   end
      #   row.save
      # end
    end
  end

  def self.bapi_goodsmvt_create_311(msegs)
    begin
      posting_success = true
      dest = JCoDestinationManager.getDestination('sap_prd')
      repos = dest.getRepository
      commit = repos.getFunction('BAPI_TRANSACTION_COMMIT')
      commit.getImportParameterList().setValue('WAIT', 'X')

      function = repos.getFunction('BAPI_GOODSMVT_CREATE')
      function.getImportParameterList().getStructure('GOODSMVT_CODE').setValue('GM_CODE', '04')

      header = function.getImportParameterList().getStructure('GOODSMVT_HEADER')
      header.setValue('PSTNG_DATE', Date.today.strftime('%Y%m%d'))
      header.setValue('DOC_DATE', Date.today.strftime('%Y%m%d'))
      header.setValue('PR_UNAME', 'LUM.LIN')
      header.setValue('HEADER_TXT', 'MES')

      lines = function.getTableParameterList().getTable('GOODSMVT_ITEM')
      msegs.each do |mseg|
        lines.appendRow()
        lines.setValue('MATERIAL', mseg[:matnr])
        lines.setValue('PLANT', mseg[:werks])
        lines.setValue('STGE_LOC', mseg[:lgort])
        lines.setValue('MOVE_STLOC', 'MES')
        lines.setValue('BATCH', mseg[:charg])
        lines.setValue('MOVE_BATCH', mseg[:charg])
        lines.setValue('MOVE_TYPE', '311')
        lines.setValue('ENTRY_QNT', mseg[:menge])
        lines.setValue('ITEM_TEXT', mseg[:project_id])
      end
      com.sap.conn.jco.JCoContext.begin(dest)
      function.execute(dest)

      returnMessage = function.getTableParameterList().getTable('RETURN')
      (1..returnMessage.getNumRows).each do |i|
        puts "#{i} Type:#{returnMessage.getString('TYPE')}, MSG:#{returnMessage.getString('MESSAGE')}"
        if returnMessage.getString('TYPE').eql?('E')
          posting_success = false
        end
        returnMessage.nextRow
      end
      commit.execute(dest)
      com.sap.conn.jco.JCoContext.end(dest)

    rescue Exception => exception
      Mail.defaults do
        delivery_method :smtp, address: '172.91.1.253', port: 25
      end
      message = "#{message} #{exception.message} #{exception.backtrace.join('\n')}"

      Mail.deliver do
        from 'lum.cl@l-e-i.com'
        to 'lum.cl@l-e-i.com, ted.meng@l-e-i.com'
        subject 'mes_t_erp_out_item bapi_goodsmvt_create_311'
        body message
      end
      posting_success = false
    end
    posting_success
  end

end