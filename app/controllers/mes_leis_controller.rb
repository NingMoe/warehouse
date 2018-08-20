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
        select barcode,matnr as pn_no,dn_no,po_no,cn_no,customer_name,aufnr as mo_no,created_at,cartonnumber,cartonnumber_updated_dt from txdb.mes_leis 
            where barcode like '%#{params[:barcode]}%' or cartonnumber like '%#{params[:barcode]}%'
        "
      @query_leis = PoReceipt.find_by_sql(sql)
    end
  end

  def query_lei_post
  end
  
  def read_barcode
	params[:printer_ip] = '127.0.0.1'
  end
    
  def process_barcode
    if params[:code_length].to_i > 0 and params[:qrcode].length != params[:code_length].to_i
      render js: "
        document.getElementById('dacuo').play();
        $('#status').html('<h1>#{params[:qrcode]} - 條碼長度不符! <h1/><br/>');
              "
    else
      begin
		records = MesLei.get_barcode_count(params[:qrcode])
		pack_qty = params[:pack_qty]
		customer_name = params[:customer_name]
		printer_ip = params[:printer_ip]
		counter = 0
		num = params[:counter]
		
		carton_num = ((params[:counter].to_i) / (pack_qty.to_i) + 1)
	    carton_number = carton_num.to_s.rjust(4, '0')
	    old_carton_number = carton_num.to_s.rjust(4, '0')
		
		number = 1
		
		printer_ip = '127.0.0.1' if printer_ip.blank?
		
		if !records.blank?
		  
		  sql = "insert into txdb.mes_leis (barcode,cartonnumber,created_at,matnr,aufnr,customer_name) values ('#{params[:qrcode]}','#{params[:carton_number]}',sysdate,'#{params[:matnr]}','#{params[:aufnr]}','#{customer_name}')"
		  PoReceipt.connection.execute(sql)
		  
		  counter = MesLei.get_mes_leis_count(params[:aufnr])
		  carton_number = ((counter.to_i)/(params[:pack_qty].to_i)+1).to_s.rjust(4, '0')
		  old_carton_number = params[:carton_number]
		  
		  #扫条码数达到包装数量时，自动增加箱号
		  if (counter.to_i % pack_qty.to_i) == 0 and counter.to_i != 0
			#IP不是127.0.0.1时，可以打印
			if !printer_ip.eql?'127.0.0.1'
				cn_number = "#{params[:aufnr].rjust(12, '0')}C#{old_carton_number.to_s.rjust(4, '0')}"
				MesLei.print_outside_box_label(customer_name, params[:aufnr].rjust(12, '0'), '', '', cn_number, pack_qty, printer_ip)
			end
		  end
		  
          code_length_str = ''
          code_length_str = "$('#code_length').val('#{params[:qrcode].length}');" if params[:code_length].to_i == 0
          render js: "
          $('#status').html('<h1><p style=\"color:green\">#{params[:qrcode]} - 條碼正確 </p></h1><br/>');
          $('#counter').val('#{counter}');
          $('#pack_qty').val('#{pack_qty}');
          $('#carton_number').val('#{carton_number}');
          #{code_length_str};
                 "
		else
          counter = MesLei.get_mes_leis_count(params[:aufnr])
		  
          code_length_str = ''
          code_length_str = "$('#code_length').val('#{params[:qrcode].length}');" if params[:code_length].to_i == 0
          render js: "
          $('#status').html('<h1><p style=\"color:red\">#{params[:qrcode]} - 條碼重複. </p></h1><br/>');
          $('#counter').val('#{counter}');
          $('#pack_qty').val('#{pack_qty}');
          $('#carton_number').val('#{carton_number}');
          #{code_length_str};
                 "		
		end
      rescue
        render js: "
        document.getElementById('dacuo').play();
        $('#status').html('<h1><p style=\"color:red\">#{params[:qrcode]} - 條碼重複! </p></h1><br/>');
              "
      end
    end
  end
  
  def get_product_order
	#carton_number = '0001'
	werk = '381A'
	customer_name = ''
	list = MesLei.get_product_order(params[:aufnr].rjust(12, '0'))
	if list.blank?
      render js: "
             $('#matnr').val('');
             $('#aufnr').val('');
             $('#counter').val('');
             $('#code_length').val('');
             $('#pack_qty').val('');
             $('#carton_number').val('');
             $('#werk').val('');
             $('#customer_name').val('');
             $('#aufnr').focus();
             alert('工單號碼輸入錯誤!');
             "
    else
      rows = MesLei.get_mes_leis(list[0])
      pack_qty = MesLei.get_carton_number(list[1],list[2])
      results = MesLei.get_aufnr_cartonnumber(list[0])
	  customer_name = MesLei.get_kunnr(list[1],list[2])
	  carton_number = results[2]
	  num = rows[0].to_i
	  carton_number = '0001' if carton_number.blank?
	  
	  carton_num = (num.to_i / pack_qty.to_i) + 1
	  carton_number = carton_num.to_s.rjust(4, '0')
	  
      render js: "
             $('#matnr').val('#{list[1]}');
             $('#aufnr').val('#{list[0]}');
             $('#counter').val('#{rows[0]}');
             $('#code_length').val('#{rows[1]}');
             $('#pack_qty').val('#{pack_qty}');
             $('#carton_number').val('#{carton_number}');
             $('#werk').val('#{werk}');
             $('#customer_name').val('#{customer_name}');
             "
    end
  end

  def get_product_orders
    aufnr = params[:aufnr]
    @customer_number = aufnr
	@pn_number = aufnr
	@dn_number = aufnr
	@mo_number = aufnr
	@po_number = aufnr
  end
end
