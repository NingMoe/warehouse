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
    end
  end

  def query_cartonnumber_view
  end

  def query_cartonnumber_post
    @error_msg = nil
    barcode = params[:barcode]
    sn = MesPhicomm.query_cartonnumber(barcode)
    if sn.eql?('N/A')
      @error_msg = 'SN不存在'
    end
  end

  def print_sn_view
    program = "#{controller_name}.#{action_name}"
    @printer_ip, @printer_port = MesPhicomm.get_printer(request.ip, program)
  end

  def print_sn_post
    barcode = params[:barcode]
    printer_ip = params[:printer_ip]
    @error_msg = nil
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
    update_count = MesPhicomm.update_kcode(barcode, @kcode)
    @error_msg =  'SN或者MAC地址錯誤!' if update_count == 0
  end

  def print_color_box_label_view
    program = "#{controller_name}.#{action_name}"
    @printer_ip, @printer_port = MesPhicomm.get_printer(request.ip, program)
  end

  def print_color_box_label_post
    barcode = params[:barcode]
    printer_ip = params[:printer_ip]
    @error_msg = nil
    @mac_addr = MesPhicomm.print_color_box(barcode, printer_ip)
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
    @mac_addr = MesPhicomm.print_color_box(barcode, printer_ip)
    if @mac_addr.eql?('N/A')
      @error_msg = 'S/N不存在或者錯誤!'
    elsif not @mac_addr.present?
      @error_msg = 'S/N未和MAC地址綁定!'
    end
  end

  def print_outside_box_label_v_s
    sn_qty = params[:sn_qty]
    if sn_qty == 1
        session[:barcode1] = params[:barcode]
    elsif sn_qty == 2
        session[:barcode2] = params[:barcode]
    elsif sn_qty == 3
        session[:barcode3] = params[:barcode]
    elsif sn_qty == 4
        session[:barcode4] = params[:barcode]
    elsif sn_qty == 5
        session[:barcode5] = params[:barcode]
    elsif sn_qty == 6
        session[:barcode6] = params[:barcode]
    elsif sn_qty == 7
        session[:barcode7] = params[:barcode]
    elsif sn_qty == 8
        session[:barcode8] = params[:barcode]
    elsif sn_qty == 9
        session[:barcode9] = params[:barcode]
	session[:sn_qty] = 0
    end
    sn_qty = session[:sn_qty]
    if sn_qty < 9
	session[:sn_qty] = sn_qty + 1
    elsif sn_qty = 9
        @printer_ip, @printer_port = MesPhicomm.get_printer(request.ip, program)
    end
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

  def get_product_info
    aufnr = (params[:mo_number] || '0').rjust(12,'0')
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
