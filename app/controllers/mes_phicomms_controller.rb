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

  def update_printer
    program = params[:program]
    printer_ip = params[:printer_ip]
    MesPhicomm.update_printer(request.ip, program, printer_ip)
    render text: ''
  end

end
