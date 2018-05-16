class MesPhicommsController < ApplicationController
  skip_before_filter :authenticate_user!, except: [:change_station_view, :change_station_post]

  def index

  end
  
  def index2

  end

  def check_sn_view
  end

  def check_sn_post
    @error_msg = nil
    barcode = params[:barcode]
    sn = MesPhicomm.check_sn(barcode)
    if sn.eql?('N/A')
      @error_msg = 'SN不存在'
    else
      msg = MesPhicomm.checkRoute(barcode, "70")
      if msg.eql?("ok")
        MesPhicomm.saveNextStation(sn, "70")
        @kcode = "#{barcode} 完成过站，去下一站！"
      else
        @error_msg = msg
      end
    end
  end

  def sn_check_sn_view
  end

  def sn_check_sn_post
    @error_msg = nil
    barcode = params[:barcode]
    kcode = params[:kcode]
	#MesPhicomm.rework_one()
    sn = MesPhicomm.isExistSn(barcode)
    if sn.eql?('N/A')
      @error_msg = 'SN不存在'
    else
      if barcode.eql?(kcode)
        msg = MesPhicomm.checkRoute(barcode, "80")
        if msg.eql?("ok")
          MesPhicomm.saveNextStation(sn, "80")
          @kcode = "#{barcode} 完成过站，去下一站！"
          MesPhicomm.test_log(barcode, '80', '', '', barcode + ' 完成过站，去下一站！', '', '', '')
		  #MesPhicomm.rework_two()
        else
          @kcode = kcode
        end
      else
        @error_msg = 'SN不相同'
      end
    end
  end

  def sn_check_sn_a_view
  end

  def sn_check_sn_a_post
    @error_msg = nil
    barcode = params[:barcode]
    kcode = params[:kcode]
    sn = MesPhicomm.isExistSn(barcode)
    if sn.eql?('N/A')
      @error_msg = 'SN不存在'
    else
      if barcode.eql?(kcode)       
        @kcode = "#{barcode} 完成过站，去下一站！"
        @kcode = kcode
      else
        @error_msg = 'SN不相同'
      end
    end
  end

  def check_kcode_view
  end

  def check_kcode_post
    @error_msg = nil
    barcode = params[:barcode]
    kcode = params[:kcode]
    sn, kcode, station = MesPhicomm.check_kcode(barcode, kcode)
    if sn.eql?('N/A')
      @error_msg = 'SN不存在 '
    end
    if kcode.eql?('N/A')
      @error_msg += 'Kcode不存在'
    end

#过站检查
    msg = MesPhicomm.checkRoute(barcode, "60")
    if msg.eql?("ok")
      MesPhicomm.saveNextStation(sn, "60")
      @kcode = "完成过站，去下一站！"
      if @error_msg.eql?('N/A') or @error_msg.eql?('')
        MesPhicomm.test_log(barcode, '60', '', @kcode, @error_msg, '', '', '')
      else
        MesPhicomm.test_log(barcode, '60', '', '', @error_msg, '', '', '')
      end
    elsif msg.eql?("error")
      @error_msg = msg
    else
      @kcode = msg
      MesPhicomm.test_log(barcode, '60', '', '', msg, '', '', '')
    end
  end

  def query_cartonnumber_view
  end

  def query_cartonnumber_post
    barcode = params[:barcode]
    @sn_array = []
    sql = "select sn from txdb.phicomm_mes_001 where cartonnumber=? order by sn"
    rows = PoReceipt.find_by_sql([sql, barcode])
    rows.each {|row| @sn_array.append row.sn}
    (@sn_array.size..8).each {@sn_array.append ''}
    @error_msg = rows.present? ? '' : '外箱條碼不存在!'
  end

  def print_sn_view
    program = "#{controller_name}.#{action_name}"
    @printer_ip, @printer_port = MesPhicomm.get_printer(request.ip, program)
  end

  def print_sn_post
    barcode = params[:barcode]
    printer_ip = params[:printer_ip]
    @error_msg = nil
# 处理过站检查
    msg = MesPhicomm.checkRoute(barcode, "20")
    if msg.eql?("ok")
      @error_msg = MesPhicomm.print_sn(barcode, printer_ip)
      MesPhicomm.saveNextStation(barcode, "20")
      msg = "SN #{barcode}打印完成，去下一站！"
      MesPhicomm.test_log('#{barcode}', '20', '', '', msg, '', '', '')
    end
    if !msg.eql?("ok")
      if @error_msg.present?
        @error_msg = msg
      else
        @error_msg = "S/N不存在或者不在此站!"
      end
    end
  end

  def print_sn1_post
    barcode = params[:barcode]
    printer_ip = params[:printer_ip]
    @error_msg = nil
    @sn = MesPhicomm.print_sn1(barcode, printer_ip)
    if @sn.eql?('N/A')
      @error_msg = 'S/N不存在或者錯誤!'
    end
  end

  def print_sn2_post
    barcode = params[:barcode]
    printer_ip = params[:printer_ip]
    @error_msg = nil
    @sn = MesPhicomm.print_sn2(barcode, printer_ip)
    if @sn.eql?('N/A')
      @error_msg = 'S/N不存在或者錯誤!'
    end
  end

  def print_mac_addr_view
    program = "#{controller_name}.#{action_name}"
    @printer_ip, @printer_port = MesPhicomm.get_printer(request.ip, program)
  end

  def print_mac_addr_post
    barcode = params[:barcode]
    printer_ip = params[:printer_ip]
    @error_msg = nil
    @mac_addr = MesPhicomm.print_mac_addr(barcode, printer_ip)
    if @mac_addr.eql?('N/A')
      @error_msg = 'S/N不存在或者錯誤!'
    elsif not @mac_addr.present?
      @error_msg = 'S/N未和MAC地址綁定!'
    end
  end

  def update_kcode_view

  end

  def update_kcode_post
    barcode = params[:barcode]
    @kcode = params[:kcode]
    @error_msg = nil
#过站检查

    sn = MesPhicomm.isExistSn(@kcode)
    if sn.eql?('N/A')
      msg = MesPhicomm.checkRoute(barcode, "50")
      if msg.eql?("ok")
        update_count = MesPhicomm.update_kcode(barcode, @kcode)
        if update_count != 0
          MesPhicomm.saveNextStation(barcode, "50")
          @kcode = "SN #{barcode} 完成过站，去下一站！"
        end
      end
      if !msg.eql?("ok")
        if @error_msg.present?
          @error_msg = msg
        else
          @error_msg = "S/N不存在或者不在此站!"
        end
      end
    else
      @error_msg = "KCODE存在!"
    end
#不过站检查
#update_count = MesPhicomm.update_kcode(barcode, @kcode)
#@error_msg = 'SN或者MAC地址錯誤!' if update_count == 0
  end

  def print_color_box_label_view
    program = "#{controller_name}.#{action_name}"
    @printer_ip, @printer_port = MesPhicomm.get_printer(request.ip, program)
  end

  def print_color_box_label_post
    barcode = params[:barcode]
    printer_ip = params[:printer_ip]
    @error_msg = nil

	#MesPhicomm.rework_jump('40','70')
	
#过站检查
    msg = MesPhicomm.checkRoute(barcode, "70")
    if msg.eql?("ok")
      @mac_addr = MesPhicomm.print_color_box(barcode, printer_ip)
      if @mac_addr.eql?('N/A')
        @error_msg = 'S/N不存在或者錯誤!'
      elsif not @mac_addr.present?
        @error_msg = 'S/N未和MAC地址綁定!'
      else
        MesPhicomm.saveNextStation(barcode, "70")
	    #MesPhicomm.rework_three('70')
        @kcode = "完成过站，去下一站！"
      end
    end
    if not msg.eql?("ok")
      if @error_msg.present?
        @error_msg = msg
      else
        @error_msg = "S/N不存在或者不在此站!"
      end
    end
  end
  
  def print_color_box_label_a2_view
    program = "#{controller_name}.#{action_name}"
    @printer_ip, @printer_port = MesPhicomm.get_printer(request.ip, program)
  end

  def print_color_box_label_a2_post
    barcode = params[:barcode]
    printer_ip = params[:printer_ip]
    @error_msg = nil

#过站检查
    msg = MesPhicomm.checkRoute(barcode, "70")
    if msg.eql?("ok")
      @mac_addr = MesPhicomm.print_color_box_a2(barcode, printer_ip)
      if @mac_addr.eql?('N/A')
        @error_msg = 'S/N不存在或者錯誤!'
      elsif not @mac_addr.present?
        @error_msg = 'S/N未和MAC地址綁定!'
      else
        MesPhicomm.saveNextStation(barcode, "70")
        @kcode = "完成过站，去下一站！"
      end
    end
    if not msg.eql?("ok")
      if @error_msg.present?
        @error_msg = msg
      else
        @error_msg = "S/N不存在或者不在此站!"
      end
    end
  end

  def mac_print_sn_view
    program = "#{controller_name}.#{action_name}"
    @printer_ip, @printer_port = MesPhicomm.get_printer(request.ip, program)
  end

  def mac_print_sn_post
    barcode = params[:barcode]
    printer_ip = params[:printer_ip]
    @error_msg = nil
	MesPhicomm.updateRework(barcode,'30','30')

#不过站检查
    @mac_addr = MesPhicomm.mac_print_sn(barcode, printer_ip)
    if @mac_addr.eql?('N/A')
      @error_msg = 'S/N不存在或者錯誤!'
    elsif not @mac_addr.present?
      @error_msg = 'S/N未和MAC地址綁定!'
    end
  end

  def print_nameplate_box_label_view
    program = "#{controller_name}.#{action_name}"
    @printer_ip, @printer_port = MesPhicomm.get_printer(request.ip, program)
  end

  def print_nameplate_box_label_post
    barcode = params[:barcode]
    printer_ip = params[:printer_ip]
    @error_msg = nil

#过站检查
    msg = MesPhicomm.checkRoute(barcode, "40")
    if msg.eql?("ok")
      @mac_addr = MesPhicomm.print_nameplate_box(barcode, printer_ip)
      if @mac_addr.eql?('N/A')
        @error_msg = 'S/N不存在或者錯誤!'
      elsif not @mac_addr.present?
        @error_msg = 'S/N未和MAC地址綁定!'
      else
        MesPhicomm.saveNextStation(barcode, "40")
        @kcode = "完成过站，去下一站！"
      end
    end
    if !msg.eql?("ok")
      if @error_msg.present?
        @error_msg = msg
      else
        @error_msg = "S/N不存在或者不在此站!"
      end
    end
#not guo zhan
#@mac_addr = MesPhicomm.print_nameplate_box(barcode, printer_ip)
#if @mac_addr.eql?('N/A')
#  @error_msg = 'S/N不存在或者錯誤!'
#elsif not @mac_addr.present?
#  @error_msg = 'S/N未和MAC地址綁定!'
#end
  end

  def print_outside_box_label_view
    program = "#{controller_name}.#{action_name}"
    @printer_ip, @printer_port = MesPhicomm.get_printer(request.ip, program)
    @pack_qty = 9
    @carton_number = '0001'
  end

  def print_outside_box_label_post
    @sn_array, @error_msgs, @mac_add, @carton_number = MesPhicomm.print_outside_box(params)
  end

  def update_pallet_label_view
    program = "#{controller_name}.#{action_name}"
    @printer_ip, @printer_port = MesPhicomm.get_printer(request.ip, program)
    @pack_qty = 16
    @carton_number = '00001'
  end

  def update_pallet_label_post
    @sn_array, @error_msgs, @mac_add, @carton_number = MesPhicomm.update_pallet(params)
  end

  def export_to_excel_view

  end

  def export_to_excel_post
    barcode = params[:barcode]
    sn_text = params[:sn_text]
    @sn_array = []
    @sn_array = sn_text.split(',') if sn_text.present?
    sql = "select sn from txdb.phicomm_mes_001 where (sn=?) or (cartonnumber=?) or (mac_add=?) or(kcode=?)"
    rows = PoReceipt.find_by_sql([sql, barcode, barcode, barcode, barcode])
    rows.each {|row| @sn_array.append row.sn if not @sn_array.include?(row.sn)}
    @error_msg = rows.present? ? '' : '外箱條碼不存在!'
  end

  def export_to_excel_download
    if params[:dn_no_excel].present?
      dn_no = params[:dn_no_excel]
      dn_location = ""
      sql = "select sn,partnumber,productname,woid,cartonnumber,palletnumber,storehouseid,locid,plant,mac_add as mac,kcode,factoryid,created_dt,dn_no,dn_location from txdb.phicomm_mes_001 where dn_no = '#{dn_no}'"
      rows = PoReceipt.find_by_sql(sql)
      excel = Excel.resultset(rows)
      if rows.present?
        dn_location = rows.first.dn_location
      end
      send_data excel.to_stream.read, type: "application/xlsx", filename: "#{dn_no}_#{dn_location}.xlsx"
    else
      sn_text = params[:sn_text]
      @sn_array = []
      @sn_array = sn_text.split(',') if sn_text.present?
      sql = "select sn,partnumber,productname,woid,cartonnumber,palletnumber,storehouseid,locid,plant,mac_add as mac,kcode,factoryid,created_dt from txdb.phicomm_mes_001 where sn in (?)"
      rows = PoReceipt.find_by_sql([sql, @sn_array])
      excel = Excel.resultset(rows)
      send_data excel.to_stream.read, type: "application/xlsx", filename: "filename.xlsx"

    end
  end

  def get_product_info
    aufnr = (params[:mo_number] || '0').rjust(12, '0')
    @mo_number = ''
    @model_number = ''
    @material_number = ''
    @net_weight = ''
    sql = "
      select a.aufnr,a.matnr,b.ntgew,c.kdmat,c.postx
        from sapsr3.afpo a
          join sapsr3.mara b on b.mandt='168' and b.matnr=a.matnr
          left join sapsr3.knmt c on c.mandt=a.mandt and c.kunnr='2H169' and c.matnr=a.matnr
        where a.mandt='168' and a.aufnr='#{aufnr}'
    "
    rows = Sapdb.find_by_sql(sql)
    rows.each do |row|
      @mo_number = row.aufnr
      @model_number = row.postx
      @material_number = row.kdmat
      @net_weight = row.ntgew
    end
  end

  def update_printer
    program = params[:program]
    printer_ip = params[:printer_ip]
    MesPhicomm.update_printer(request.ip, program, printer_ip)
    render text: ''
  end

  def change_station_view
    sql = "select * from txdb.phicomm_mes_users where lower(email) = ?"
    user = PoReceipt.find_by_sql([sql, current_user.email])
    @current_user_email = current_user.email
    if user.present?
      @stations = PoReceipt.find_by_sql("select stationid, stationid||' '||station||' '||stationdesc name from txdb.phicomm_mes_station order by stationid")
    else
      redirect_to mes_phicomms_path, notice: '您沒有操作權限!'
    end
  end

  def change_station_post
    if params[:datas].present? and params[:station].present?
      sn_list = text_area_to_array(params[:datas]).join("','")
	  barcode = sn_list[0,15]
      if params[:station].to_i == 10
        sql = "delete txdb.phicomm_mes_001 where sn in ('#{sn_list}') and dn_no is null and cartonnumber is null "
        PoReceipt.connection.execute(sql)
		MesPhicomm.test_log(barcode, '00', '', '#{sn_list}', ' 回退站點！', '', '', '')
      elsif params[:station].to_i <= 50 and params[:station].to_i > 10
        sql = "update txdb.phicomm_mes_001 set station = '#{params[:station]}', kcode = '', station_edit_user = '#{@current_user_email}', status = 'BACK', station_edit_dt = sysdate where dn_no is null and sn in ('#{sn_list}')"
        PoReceipt.connection.execute(sql)
      else
        sql = "update txdb.phicomm_mes_001 set station = '#{params[:station]}', station_edit_user = '#{@current_user_email}', status = 'BACK', station_edit_dt = sysdate where dn_no is null and sn in ('#{sn_list}')"
        PoReceipt.connection.execute(sql)
      end
    end
    redirect_to change_station_view_mes_phicomms_path, notice: '已經更新完成...'
  end

  def query_phicomm_view
    @query_phicomms = []
    check = "#{params[:barcode]}"
    if check.present?
      sql = "
        select mac_add,sn,kcode,station,testitem,testvalue,testresult,stime,pcname,partnumber,productname,woid,cartonnumber,palletnumber,storehouseid,locid,plant,factoryid,created_dt,updated_dt,station_up_dt,station_edit_dt,station_edit_user,status,dn_no,dn_location,dn_updated_dt,kcode_updated_dt,cartonnumber_updated_dt from txdb.phicomm_mes_001 
            where sn like '%#{params[:barcode]}%' or mac_add like '%#{params[:barcode]}%' or cartonnumber like '%#{params[:barcode]}%'
        "
      @query_phicomms = PoReceipt.find_by_sql(sql)
    end
  end

  def query_phicomm_post
  end

  def search_barcode
    @query_phicomms = []
    check = "#{params[:barcode]}"
    if check.present?
      sql = "
        select sn,partnumber,productname,woid,cartonnumber,palletnumber,storehouseid,locid,plant,mac_add as mac,kcode,factoryid from txdb.phicomm_mes_001 
            where sn like '%#{params[:barcode]}%'
        "
      @query_phicomms = PoReceipt.find_by_sql(sql)
    end
  end

  def verify_dn_no_post
    dn_no = params[:dn_no] || '0'
    sql = "select vbeln from sapsr3.likp where mandt='168' and vbeln='#{dn_no}'"
    @rows = Sapdb.find_by_sql(sql)
  end
  
  
  def check_barcode_label_view
  end

  def check_barcode_label_post
    @sn_array, @error_msgs, @init_num = MesPhicomm.check_barcode_label(params)
  end

  def barcode_link_dn_view
  end

  def barcode_link_dn_post
    barcode = params[:barcode]
    dn_no = params[:dn_no]
    dn_location = params[:dn_location]
    sql = "update txdb.phicomm_mes_001 set dn_no = '#{dn_no}', dn_location = '#{dn_location}',dn_updated_dt = sysdate where cartonnumber='#{barcode}' and station='90' and kcode is not null and mac_add is not null "
    PoReceipt.connection.execute(sql)
    @carton = 0
    @serial = 0
    sql = "
      select 'carton' typ,count(*) cnt from (select cartonnumber from txdb.phicomm_mes_001 where dn_no = '#{dn_no}' group by cartonnumber)
      union all
      select 'serial',count(*) cnt from txdb.phicomm_mes_001 where dn_no = '#{dn_no}'
    "
    PoReceipt.find_by_sql(sql).each do |row|
      if row.typ.eql?('carton')
        @carton = row.cnt
      else
        @serial = row.cnt
      end
    end

  end

end
