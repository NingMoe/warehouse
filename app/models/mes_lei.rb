class MesLei

  def self.print_outside_box(params)
    # params field
    # barcode
    # rowcounter
    # printer_ip
    # pack_qty
    # mo_number
    # carton_number
    # customer_number
    # po_number
    # pn_number
    # dn_number
    # sn1
    # sn2
    # sn3
    # sn4
    # sn5
    # sn6
    # sn7
    # sn8
    # sn9
    # sn10
    # sn11
    # sn12
    # sn13
    # sn14
    # sn15
    # sn16
    error_msgs = []
    error_msgs.append "打印機IP不可為空!" if params[:printer_ip].blank?
    error_msgs.append "工單號碼不可為空!" if params[:mo_number].blank?
    error_msgs.append "包裝數量不可為空!" if params[:pack_qty].blank?
    error_msgs.append "包裝箱號不可為空!" if params[:carton_number].blank?
    error_msgs.append "客户名称不可為空!" if params[:customer_number].blank?
    error_msgs.append "PO不可為空!" if params[:po_number].blank?
    error_msgs.append "P/N不可為空!" if params[:pn_number].blank?
    error_msgs.append "D/N不可為空!" if params[:dn_number].blank?
    error_msgs.append "掃入條碼不可為空!" if params[:barcode].blank?

    sn_array = []
    #error_msgs.append "條碼重複掃描!" if sn_array.include?(params[:barcode])

    sql = "select barcode from txdb.mes_leis where barcode=? "
    records = PoReceipt.find_by_sql([sql, params[:barcode]])
    if !records.present?
      sql = "insert into txdb.mes_leis (barcode,created_at) values ('#{params[:barcode]}',sysdate)"
      PoReceipt.connection.execute(sql)
	  mac_add = params[:barcode]
    end

    carton_number = (params[:carton_number] || '1').to_i
	customer_number = params[:customer_number]
	pn_number = params[:pn_number]
	dn_number = params[:dn_number]
	po_number = params[:po_number]
	mo_number = params[:mo_number]
	printer_ip = params[:printer_ip]
	pack_qty = params[:pack_qty]
    if error_msgs.blank?
      #加入SN數組
      sn_array.append params[:barcode]
      if (params[:pack_qty] || '1').to_i == sn_array.size
        cn_number = "#{params[:mo_number]}C#{carton_number.to_s.rjust(4, '0')}"
        sn_array_text = sn_array.join("','")
        sql = "update txdb.mes_leis set pn_no = '#{pn_number}',dn_no = '#{dn_number}',po_no = '#{po_number}',mo_no = '#{mo_number}',cn_no = '#{cn_number}',customer_name = '#{customer_number}',cartonnumber = '#{cn_number}',cartonnumber_updated_dt = sysdate where barcode in ('#{sn_array_text}')"
        PoReceipt.connection.execute(sql)
        #避免SN數組少於250個元素
        (sn_array.size..params[:pack_qty].to_i).each {sn_array.append ''}

        # 打印标签
		if !printer_ip.eql? '127.0.0.1'
			print_outside_box_label(customer_number, pn_number, dn_number, po_number, cn_number, pack_qty, printer_ip)
		end
        carton_number += 1
        sn_array.clear
      end
    end
    (sn_array.size..params[:pack_qty].to_i).each {sn_array.append ''}
    return [sn_array, error_msgs, mac_add, carton_number.to_s.rjust(4, '0')]
  end

  def self.print_outside_box_label(customer_number, pn_number, dn_number, po_number, cn_number, pack_qty, printer_ip)
    zpl_command = "
      	^XA~TA000~JSN^LT0^MNW^MTT^PON^PMN^LH0,0^PR4,4~SD28^JUS^LRN^CI0^XZ
	^XA^CI28
	^MMT
	^PW1228
	^LL1772
	^LS0
	^FT280,400^A0N,240,240^FD#{customer_number}^FS
	^FT45,600^A0N,100,100^FH\^FDP/N:#{pn_number}^FS
	^FT45,900^A0N,100,100^FH\^FDD/N:#{dn_number}^FS
	^FT45,1200^A0N,100,100^FH\^FDPO:#{po_number}^FS
	^FT45,1500^A0N,100,100^FH\^FDCN:#{cn_number}^FS
	^FT45,1800^A0N,100,100^FH\^FDQTY:#{pack_qty}^FS
	^PQ1,0,1,Y^XZ
    "
    s = TCPSocket.new("#{printer_ip}", '9100')
    s.write zpl_command
    s.close
  end

  def self.get_printer(pc_ip, program)
    # pc_ip
    # program
    # printer_ip
    # printer_port
    sql = "select printer_ip, printer_port from txdb.mes_leis_printer where pc_ip=? and program=?"
    records = PoReceipt.find_by_sql([sql, pc_ip, program])
    if records.present?
      return [records.first.printer_ip, records.first.printer_port]
    else
      sql = "insert into txdb.mes_leis_printer (pc_ip, program, printer_port) values ('#{pc_ip}','#{program}','9100')"
      PoReceipt.connection.execute(sql)
      return ['', '9100']
    end
  end

  def self.update_printer(pc_ip, program, printer_ip, printer_port = '9100')
    sql = "update txdb.mes_leis_printer set printer_ip='#{printer_ip}', printer_port='#{printer_port}' where pc_ip='#{pc_ip}' and program='#{program}'"
    PoReceipt.connection.execute(sql)
  end

  def self.save_barcode(barcode)
    # barcode
    sql = "select barcode from txdb.mes_leis where barcode=? "
    records = PoReceipt.find_by_sql([sql, params[:barcode]])
    if !records.present?
      sql = "insert into txdb.mes_leis (barcode,created_at) values ('#{params[:barcode]}',sysdate)"
      PoReceipt.connection.execute(sql)
    end
  end
  
  def self.get_product_order(aufnr)
    sql = "select aufnr,matnr,pwerk from sapsr3.afpo@SAPP where mandt='168' and aufnr = ?"
    records = PoReceipt.find_by_sql([sql, aufnr])
    if records.present?
      return [records.first.aufnr, records.first.matnr, records.first.pwerk]
    else
      return ['', '', '']
    end
  end
  
  def self.get_mes_leis(aufnr)
    sql = "select count(*) counter, nvl(max(length(barcode)),0) code_length from txdb.mes_leis where aufnr = ?"
    records = PoReceipt.find_by_sql([sql, aufnr])
    if records.present?
      return [records.first.counter, records.first.code_length]
    else
      return ['0', '0']
    end
  end
  
  def self.get_mes_leis_count(aufnr)
    sql = "select count(*) c from txdb.mes_leis where aufnr = ?"
    records = PoReceipt.find_by_sql([sql, aufnr])
    if records.present?
      return records.first.c
    else
      return '0'
    end
  end
  
  def self.get_aufnr_cartonnumber_count(aufnr, cartonnumber)
    sql = "select count(*) c from txdb.mes_leis where cartonnumber = ? and aufnr = ?"
    records = PoReceipt.find_by_sql([sql, cartonnumber, aufnr])
    if records.present?
      return records.first.c
    else
      return '0001'
    end
  end
  
  def self.get_aufnr_cartonnumber(aufnr)
    sql = "select aufnr,matnr,cartonnumber,count(*) count from txdb.mes_leis group by aufnr,matnr,cartonnumber having aufnr = ? and cartonnumber in ( with maxc as ( select aufnr,matnr,cartonnumber,count(*) count from txdb.mes_leis	group by aufnr,matnr,cartonnumber having aufnr = ? ) select max(cartonnumber) from maxc )"
    records = PoReceipt.find_by_sql([sql, aufnr, aufnr])
    if records.present?
      return [records.first.aufnr, records.first.matnr, records.first.cartonnumber, records.first.count]
    else
      return [aufnr, '', '0001', '0']
    end
  end
  
  def self.get_barcode_count(barcode)
    sql = "select count(*) c from txdb.mes_leis where barcode = ?"
    records = PoReceipt.find_by_sql([sql, barcode])
    if records.present?
      return records.first.c
    else
      return ''
    end
  end
  
  def self.get_carton_number(matnr, werk)
    #sql = "select rtrim(substr(a.potx1,INSTR(a.potx1,'/',-1,1)+1,INSTR(a.potx1,' ',-1,1)-INSTR(a.potx1,'/',-1,1))) as pack_qty from it.sbomxtb@ORACLETW a join sapsr3.mara@sapp b on b.mandt='168' and b.matnr=a.cmatnr where a.pmatnr=? and a.werks=? and (a.cmaktx like 'CARTON%')"
	sql = "select replace(replace(replace(trim(substr(a.potx1,INSTR(a.potx1,'/',-1,1)+1,3)),')',''),',',''),'(','') as pack_qty from it.sbomxtb@ORACLETW a join sapsr3.mara@sapp b on b.mandt='168' and b.matnr=a.cmatnr where a.pmatnr=? and a.werks=? and (a.cmaktx like 'CARTON%')"
    records = PoReceipt.find_by_sql([sql, matnr, werk])
    if records.present?
      return records.first.pack_qty
    else
      return ''
    end
  end
  
  def self.get_kunnr(matnr, werk)
    sql = "select b.sortl from sapsr3.knmt@sapp a, sapsr3.kna1@sapp b where a.mandt='168' and a.kunnr = b.kunnr and a.matnr= ? "
    records = PoReceipt.find_by_sql([sql, matnr])
    if records.present?
      return records.first.sortl
    else
      return ''
    end
  end
  
  def self.felixtest
    dn_number = "MU05BS1050-A10S-A"
    po_number = "11009209921"
    pn_number = "6961P05102DLG"
    customer_number = "ALPHA"
    cn_number = "CBDEC2101K00474"
	pack_qty = 120
    zpl_command = "
      	^XA~TA000~JSN^LT0^MNW^MTT^PON^PMN^LH0,0^PR4,4~SD28^JUS^LRN^CI0^XZ
	^XA^CI28
	^MMT
	^PW1228
	^LL1772
	^LS0
	^FT280,400^A0N,240,240^FD#{customer_number}^FS
	^FT35,700^A0N,100,100^FH\^FDP/N:#{pn_number}^FS
	^FT35,1000^A0N,100,100^FH\^FDD/N:#{dn_number}^FS
	^FT35,1300^A0N,100,100^FH\^FDPO:#{po_number}^FS
	^FT35,1600^A0N,100,100^FH\^FDCN:#{cn_number}^FS
	^FT35,1900^A0N,100,100^FH\^FDQTY:#{pack_qty}^FS
	^PQ1,0,1,Y^XZ
    "
    s = TCPSocket.new('172.91.39.34', '9100')
    s.write zpl_command
    s.close
  end

end

