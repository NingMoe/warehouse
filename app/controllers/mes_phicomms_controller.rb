class MesPhicommsController < ApplicationController
  skip_before_filter :authenticate_user!

  def index

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
    if barcode.eql?(kcode)
      msg = MesPhicomm.checkRoute(barcode, "80")
      if msg.eql?("ok")
        MesPhicomm.saveNextStation(sn, "80")
        @kcode = "#{barcode} 完成过站，去下一站！"
      else        
        @kcode = kcode
      end
    else
      @error_msg = 'SN不相同'
    end
  end

  def check_kcode_view
  end

  def check_kcode_post
    @error_msg = nil
    barcode = params[:barcode]
    kcode = params[:kcode]
    sn,kcode,station = MesPhicomm.check_kcode(barcode, kcode)
    if sn.eql?('N/A')
      @error_msg = 'SN不存在'
    end
    if kcode.eql?('N/A')
      @error_msg += 'Kcode不存在'
    end

#过站检查
    msg = MesPhicomm.checkRoute(barcode, "60")
    if msg.eql?("ok")
      MesPhicomm.saveNextStation(sn, "60")
      @kcode = "完成过站，去下一站！"
    elsif msg.eql?("error")
      @error_msg = msg
    else
      @kcode = msg
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
# 先不处理过站检查
    msg = MesPhicomm.checkRoute(barcode, "20")
    if msg.eql?("ok")
      MesPhicomm.saveNextStation(sn, "20")
      @kcode = "完成过站，去下一站！"
    elsif msg.eql?("error")
      @error_msg = msg
    else
      @kcode = msg
    end
    @sn = MesPhicomm.print_sn(barcode, printer_ip)
    if @sn.eql?('N/A')
      @error_msg = 'S/N不存在或者錯誤!'
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
    msg = MesPhicomm.checkRoute(barcode, "50")
    if msg.eql?("ok")
      update_count = MesPhicomm.update_kcode(barcode, @kcode)
      if update_count == 0
        MesPhicomm.saveNextStation(sn, "50")
        @kcode = "完成过站，去下一站！"
      end
    elsif msg.eql?("error")
      @error_msg = msg
    else
      @kcode = msg
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

#过站检查
    msg = MesPhicomm.checkRoute(barcode, "70")
    if msg.eql?("ok")
      @mac_addr = MesPhicomm.print_color_box(barcode, printer_ip)
      if @mac_addr.eql?('N/A')
        @error_msg = 'S/N不存在或者錯誤!'
      elsif not @mac_addr.present?
        @error_msg = 'S/N未和MAC地址綁定!'
      else
        MesPhicomm.saveNextStation(sn, "70")
        @kcode = "完成过站，去下一站！"
      end
    elsif msg.eql?("error")
      @error_msg = msg
    else
      @kcode = msg
    end

#不过站检查
#    @mac_addr = MesPhicomm.print_color_box(barcode, printer_ip)
#    if @mac_addr.eql?('N/A')
#      @error_msg = 'S/N不存在或者錯誤!'
#    elsif not @mac_addr.present?
#      @error_msg = 'S/N未和MAC地址綁定!'
#    end
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
        MesPhicomm.saveNextStation(sn, "40")
        @kcode = "完成过站，去下一站！"
      end
    elsif msg.eql?("error")
      @error_msg = msg
    else
      @kcode = msg
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
#过站检查
    msg = MesPhicomm.checkRoute(barcode, "90")
    if msg.eql?("ok")      
      @sn_array, @error_msgs, @mac_add, @carton_number = MesPhicomm.print_outside_box(params)
      MesPhicomm.saveNextStation(sn, "90")
      @kcode = "完成过站，去下一站！"
    elsif msg.eql?("error")
      @error_msg = msg
    else
      @kcode = msg
    end
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
    sn_text = params[:sn_text]
    @sn_array = []
    @sn_array = sn_text.split(',') if sn_text.present?
    sql = "select sn,partnumber,productname,woid,cartonnumber,palletnumber,storehouseid,locid,plant,mac_add as mac,kcode,factoryid from txdb.phicomm_mes_001 where sn in (?)"
    rows = PoReceipt.find_by_sql([sql, @sn_array])
    excel = Excel.resultset(rows)
    send_data excel.to_stream.read, type: "application/xlsx", filename: "filename.xlsx"
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

end
