class MesTErpOutProject < ActiveRecord::Base
  require 'java'
  java_import 'java.io.File'
  java_import 'java.io.FileOutputStream'
  java_import 'java.util.Properties'
  java_import 'com.sap.conn.jco.JCoDestination'
  java_import 'com.sap.conn.jco.JCoDestinationManager'
  java_import 'com.sap.conn.jco.ext.DestinationDataEventListener'
  java_import 'com.sap.conn.jco.ext.DestinationDataProvider'
  java_import 'com.sap.conn.jco.JCoContext'

  self.table_name = :t_erp_out_project
  establish_connection :leimes

  def self.issue
    sql = "select to_char(wm_concat(chr(39)||data_value||chr(39))) matkl from t_data_dictionary where data_model_code = 'ITEM_GROUP' and use_flag = 0"
    rows = MesTErpOutProject.find_by_sql(sql)
    matkls = rows.first.matkl

    while true
      project = MesTErpOutProject.find_by("status=' ' and ((sysdate - updated_time)*24*60) > 15")
      break if project.blank?

      MesTErpOutProject.connection.execute("update t_erp_out_project set updated_time = sysdate where teop_id=#{project.teop_id}")
      sql = "
        select a.rsnum, a.rspos, a.matnr, a.werks, a.lgort, a.rsart,
               a.bdmng, a.enmng, (a.bdmng - a.enmng) bal_qty,
               a.posnr, d.arbpl, a.aufnr
          from sapsr3.resb a
                 join sapsr3.afvc  c on c.mandt=a.mandt and c.aufpl=a.aufpl and c.aplzl=a.aplzl and c.plnfl=a.plnfl
                 join sapsr3.crhd  d on d.mandt=c.mandt and d.objty='A' and d.objid=c.arbid and a.bdter between d.begda and d.endda and d.arbpl=?
          where a.mandt='168' and a.dumps=' ' and a.bdmng <> 0 and a.xloek=' ' and a.aufnr=? and (a.bdmng - a.enmng) > 0
            and a.matkl in (#{matkls})
      "
      resbs = Sapdb.find_by_sql([sql, project.work_center, project.project_id])
      if resbs.present?
        mat_refs = []
        resbs.each do |resb|
          mat_ref = "('#{resb.werks}','#{resb.matnr}')"
          mat_refs.append mat_ref unless mat_refs.include?(mat_ref)
        end
        sql = "
          select matnr,werks,lgort,charg,clabs from sapsr3.mchb
            where mandt='168' and (werks,matnr) in (#{mat_refs.join(',')}) and clabs > 0
            order by werks,matnr,charg,lgort
        "
        mchbs = {}
        rows = Sapdb.find_by_sql(sql)
        rows.each do |row|
          key = "#{row.werks}.#{row.matnr}"
          mchbs[key] = [] unless mchbs.key?(key)
          mchbs[key].append(row)
        end

        msegs = []
        resbs.each do |resb|
          key = "#{resb.werks}.#{resb.matnr}"
          if mchbs.key?(key)
            mchbs[key].each do |mchb|
              if mchb.clabs > 0
                ws_qty = mchb.clabs > resb.bal_qty ? resb.bal_qty : mchb.clabs
                resb.bal_qty -= ws_qty
                mchb.clabs -= ws_qty
                msegs.append({werks: mchb.werks, matnr: mchb.matnr, lgort: mchb.lgort, charg: mchb.charg, menge: ws_qty, resb: resb})
              end
              break if resb.bal_qty == 0
            end
          end
        end
        bapi_goodsmvt_create_261(msegs) if msegs.present?
        msegs.each do |mseg|
          puts mseg
        end
        break
      else
        MesTErpOutProject.connection.execute("update t_erp_out_project set status='X', updated_time = sysdate where teop_id=#{project.teop_id}")
      end
    end
  end

  def self.bapi_goodsmvt_create_261(msegs)
#    begin
      aufnr = (msegs.first)[:resb].aufnr
      dest = JCoDestinationManager.getDestination('sap_prd')
      repos = dest.getRepository
      commit = repos.getFunction('BAPI_TRANSACTION_COMMIT')
      commit.getImportParameterList().setValue('WAIT', 'X')

      function = repos.getFunction('BAPI_GOODSMVT_CREATE')
      function.getImportParameterList().getStructure('GOODSMVT_CODE').setValue('GM_CODE', '03')

      header = function.getImportParameterList().getStructure('GOODSMVT_HEADER')
      header.setValue('PSTNG_DATE', Date.today.strftime('%Y%m%d'))
      header.setValue('DOC_DATE', Date.today.strftime('%Y%m%d'))
      header.setValue('PR_UNAME', 'LUM.LIN')
      header.setValue('HEADER_TXT', aufnr)

      lines = function.getTableParameterList().getTable('GOODSMVT_ITEM')
      line_id = 0
      msegs.each do |mseg|
        resb = mseg[:resb]
        line_id = line_id + 1
        lines.appendRow()
        lines.setValue('LINE_ID', line_id)
        lines.setValue('MATERIAL', mseg[:matnr])
        lines.setValue('PLANT', mseg[:werks])
        lines.setValue('BATCH', mseg[:charg])
        lines.setValue('STGE_LOC', mseg[:lgort])
        lines.setValue('MOVE_TYPE', '261')
        #lines.setValue('XSTOB', 'X') #if 262
        lines.setValue('ORDERID', resb.aufnr)
        lines.setValue('RESERV_NO', resb.rsnum)
        lines.setValue('RES_ITEM', resb.rspos)
        lines.setValue('RES_TYPE', resb.rsart)
        lines.setValue('ENTRY_QNT', mseg[:menge])
      end

      com.sap.conn.jco.JCoContext.begin(dest)
      function.execute(dest)

      returnMessage = function.getTableParameterList().getTable('RETURN')
      (1..returnMessage.getNumRows).each do |i|
        puts "#{i} Type:#{returnMessage.getString('TYPE')}, MSG:#{returnMessage.getString('MESSAGE')}"
        returnMessage.nextRow
      end
      mblnr = function.getExportParameterList().getString('MATERIALDOCUMENT')
      mjahr = function.getExportParameterList().getString('MATDOCUMENTYEAR')

      puts "#{mblnr}.#{mjahr}"

      #commit.execute(dest)
      com.sap.conn.jco.JCoContext.end(dest)

#    rescue Exception => exception
#      puts exception
#    end

  end

end
