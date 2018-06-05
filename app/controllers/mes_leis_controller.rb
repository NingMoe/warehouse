class MesLeisController < ApplicationController
  skip_before_filter :authenticate_user!

  def index

  end
  
  def print_outside_box_label_view
    program = "#{controller_name}.#{action_name}"
    @printer_ip, @printer_port = MesLei.get_printer(request.ip, program)
    @pack_qty = 120
    @carton_number = '0001'
  end

  def print_outside_box_label_post
    @sn_array, @error_msgs, @mac_add, @carton_number = MesLei.print_outside_box(params)
  end

  def update_printer
    program = params[:program]
    printer_ip = params[:printer_ip]
    MesLei.update_printer(request.ip, program, printer_ip)
    render text: ''
  end
  
  def query_lei_view
    @query_leis = []
    check = "#{params[:barcode]}"
    if check.present?
      sql = "
        select barcode,pn_no,dn_no,po_no,cn_no,customer_name,mo_no,created_at,cartonnumber,cartonnumber_updated_dt from txdb.mes_leis 
            where barcode like '%#{params[:barcode]}%' or cartonnumber like '%#{params[:barcode]}%'
        "
      @query_leis = PoReceipt.find_by_sql(sql)
    end
  end

  def query_lei_post
  end
end
