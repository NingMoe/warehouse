class MesLeisController < ApplicationController

  def index

  end
  
  def print_outside_box_label_view
    program = "#{controller_name}.#{action_name}"
    @printer_ip, @printer_port = MesLei.get_printer(request.ip, program)
    @pack_qty = 9
    @carton_number = '0001'
  end

  def print_outside_box_label_post
    @sn_array, @error_msgs, @mac_add, @carton_number = MesLei.print_outside_box(params)
  end
end
