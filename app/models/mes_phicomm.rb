class MesPhicomm

  def self.check_sn(barcode_sn)
    sql = "select sn from txdb.phicomm_mes_001 where sn=?"
    records = PoReceipt.find_by_sql([sql, barcode_sn])
    if records.present?
      sn = records.first.sn
    else
      sn = 'N/A'
    end
    sn
  end

  def self.print_mac_addr(barcode_sn, printer_ip)
    sql = "select mac_add from txdb.phicomm_mes_001 where sn=?"
    records = PoReceipt.find_by_sql([sql, barcode_sn])
    if records.present?
      mac_add = records.first.mac_add
      print_mac_addr_label(mac_add, printer_ip)
    else
      mac_add = 'N/A'
    end
    mac_add
  end

  def self.print_mac_addr_label(mac_add, printer_ip)
    zpl_command = "
        ^XA~TA000~JSN^LT0^MNW^MTT^PON^PMN^LH0,0^JMA^PR4,4~SD15^JUS^LRN^CI0^XZ
        ^XA
        ^MMT
        ^PW531
        ^LL0177
        ^LS0
        ^BY2,3,56^FT76,137^BCN,,N,N
        ^FD>:#{mac_add}^FS
        ^FT138,66^A0N,25,24^FH
        ^FD#{mac_add}^FS
        ^FT90,66^A0N,25,24^FH
        ^FDSN:^FS
        ^PQ1,0,1,Y^XZ
    "
    s = TCPSocket.new(printer_ip, '9100')
    s.write zpl_command
    s.close
  end

  def self.print_sn(barcode_sn, printer_ip)
    sql = "select sn from txdb.phicomm_mes_001 where sn=?"
    records = PoReceipt.find_by_sql([sql, barcode_sn])
    if records.present?
      sn = records.first.sn
      print_sn_label(barcode_sn, printer_ip)
    else
      sn = 'N/A'
    end
    sn
  end

  def self.print_sn_label(sn, printer_ip)
    zpl_command = "
      ^XA~TA000~JSN^LT0^MNW^MTT^PON^PMN^LH0,0^JMA^PR4,4~SD15^JUS^LRN^CI0^XZ
      ^XA
      ^MMT
      ^PW531
      ^LL0177
      ^LS0
      ^BY2,3,56^FT76,137^BCN,,N,N
      ^FD>:#{sn}^FS
      ^FT138,66^A0N,25,24^FH
      ^FD#{sn}^FS
      ^FT90,66^A0N,25,24^FH
      ^FDSN:^FS
      ^PQ1,0,1,Y^XZ
    "
    s = TCPSocket.new(printer_ip, '9100')
    s.write zpl_command
    s.close
  end

  def self.print_sn1(barcode_sn, printer_ip)
    sql = "select sn from txdb.phicomm_mes_001 where sn=?"
    records = PoReceipt.find_by_sql([sql, barcode_sn])
    if records.present?
      sn = records.first.sn
      print_sn1_label(barcode_sn, printer_ip)
    else
      sn = 'N/A'
    end
    sn
  end

  def self.print_sn1_label(sn, printer_ip)
    zpl_command = "
      ^XA~TA000~JSN^LT0^MNW^MTT^PON^PMN^LH0,0^JMA^PR4,4~SD15^JUS^LRN^CI0^XZ
      ^XA
      ^MMT
      ^PW531
      ^LL0177
      ^LS0
      ^BY2,3,56^FT58,137^BCN,,N,N
      ^FD>:#{sn}^FS
      ^FT121,66^A0N,25,24^FH
      ^FD#{sn}^FS
      ^FT73,66^A0N,25,24^FH
      ^FDSN:^FS
      ^PQ1,0,1,Y^XZ
    "
    s = TCPSocket.new(printer_ip, '9100')
    s.write zpl_command
    s.close
  end

  def self.print_sn2(barcode_sn, printer_ip)
    sql = "select sn from txdb.phicomm_mes_001 where sn=?"
    records = PoReceipt.find_by_sql([sql, barcode_sn])
    if records.present?
      sn = records.first.sn
      print_sn2_label(barcode_sn, printer_ip)
    else
      sn = 'N/A'
    end
    sn
  end

  def self.print_sn2_label(sn, printer_ip)
    zpl_command = "
      ^XA~TA000~JSN^LT0^MNW^MTT^PON^PMN^LH0,0^JMA^PR4,4~SD15^JUS^LRN^CI0^XZ
      ^XA
      ^MMT
      ^PW531
      ^LL0177
      ^LS0
      ^BY2,3,56^FT76,137^BCN,,N,N
      ^FD>:#{sn}^FS
      ^FT138,66^A0N,25,24^FH
      ^FD#{sn}^FS
      ^FT90,66^A0N,25,24^FH
      ^FDSN:^FS
      ^PQ1,0,1,Y^XZ
    "
    s = TCPSocket.new(printer_ip, '9100')
    s.write zpl_command
    s.close
  end

  def self.print_color_box(barcode_sn, printer_ip)
    sql = "select mac_add from txdb.phicomm_mes_001 where sn=?"
    records = PoReceipt.find_by_sql([sql, barcode_sn])
    if records.present?
      mac_add = records.first.mac_add
      print_color_box_label(barcode_sn, printer_ip)
    else
      mac_add = 'N/A'
    end
    mac_add
  end

  def self.print_color_box_label(sn, printer_ip)
    zpl_command = "
      ^XA~TA000~JSN^LT0^MNW^MTT^PON^PMN^LH0,0^JMA^PR4,4~SD15^JUS^LRN^CI0^XZ
      ^XA
      ^MMT
      ^PW768
      ^LL0413
      ^LS0
      ^FT93,239^A0N,22,19^FH\^FDS/N:^FS
      ^FT129,240^A0N,21,21^FH\^FD#{sn}^FS
      ^BY1,3,47^FT92,295^BCN,,N,N
      ^FD>:#{sn}^FS
      ^PQ1,0,1,Y^XZ
    "
    s = TCPSocket.new(printer_ip, '9100')
    s.write zpl_command
    s.close
  end

  def self.print_outside_box(params)
    # params field
    # barcode
    # rowcounter
    # printer_ip
    # pack_qty
    # mo_number
    # carton_number
    # sn1
    # sn2
    # sn3
    # sn4
    # sn5
    # sn6
    # sn7
    # sn8
    # sn9
    error_msgs = []
    error_msgs.append "打印機IP不可為空!" if params[:printer_ip].blank?
    error_msgs.append "工單號碼不可為空!" if params[:mo_number].blank?
    error_msgs.append "包裝數量不可為空!" if params[:pack_qty].blank?
    error_msgs.append "包裝箱號不可為空!" if params[:carton_number].blank?
    error_msgs.append "掃入條碼不可為空!" if params[:barcode].blank?

    sn_array = []
    (1..9).each do |i|
      sn_array.append params["sn#{i}"] if params["sn#{i}"].present?
    end
    error_msgs.append "條碼重複掃描!" if sn_array.include?(params[:barcode])

    sql = "select mac_add from txdb.phicomm_mes_001 where sn=?"
    records = PoReceipt.find_by_sql([sql, params[:barcode]])
    if records.present?
      mac_add = records.first.mac_add
      error_msgs.append "S/N未和MAC地址綁定!" if mac_add.blank?
    else
      error_msgs.append "S/N不存在或者錯誤!"
    end

    carton_number = (params[:carton_number] || '1').to_i
    if error_msgs.blank?
      #加入SN數組
      sn_array.append params[:barcode]
      if (params[:pack_qty] || '1').to_i == sn_array.size
        label_barcode = "#{params[:mo_number]}C#{carton_number.to_s.rjust(4, '0')}"
        sn_array_text = sn_array.join("','")
        sql = "update txdb.phicomm_mes_001 set cartonnumber = '#{label_barcode}' where sn in ('#{sn_array_text}')"
        PoReceipt.connection.execute sql
        #避免SN數組少於9個元素
        (sn_array.size..8).each {sn_array.append ''}

        # 打印标签
        #print_outside_box_label(label_barcode, sn_array, params)
        carton_number += 1
        sn_array.clear
      end
    end
    (sn_array.size..8).each {sn_array.append ''}
    return [sn_array, error_msgs, mac_add, carton_number.to_s.rjust(4, '0')]
    #print_outside_box_label(barcode_sn, printer_ip)
  end

  def self.print_outside_box_label(label_barcode, sn_array, params)
    zpl_command = "
      ^XA~TA000~JSN^LT0^MNW^MTT^PON^PMN^LH0,0^JMA^PR4,4~SD15^JUS^LRN^CI0^XZ
      ^XA
      ^MMT
      ^PW1228
      ^LL1772
      ^LS0

      ^FT347,180^A0N,74,88^FH
      ^FDPHICOMM\8D3\03\00^FS
      ^FH\^FD\90\D8\A7\9CS\A2\A5\14\D2\EC \ED\D6\00\00\00\00n\0A\05|\D1\07E\03H\FC^FS
      ^FT69,499^A0N,42,40^FH\^FD\D8\84\A7\0A\05^FS
      ^FT777,490^A0N,42,40^FH\^FD\D2\EC\B5\0A\05^FS
      ^FT782,412^A0N,42,38^FH\^FD\B5\D8\A7\0A\05^FS
      ^FT1011,662^A0N,42,38^FH\^FD\99\D11\A3 |\00\00\00^FS
      ^FT189,655^A0N,42,122^FH\^FD11.22kg^FS
      ^FT74,654^A0N,42,40^FH\^FD \AF\99\0A\05^FS
      ^FT881,488^A0N,42,124^FH\^FD9pcs^FS
      ^FT876,413^A0N,42,72^FH\^FD911000053^FS
      ^FT186,408^A0N,42,117^FH\^FDTC1^FS
      ^FT66,409^A0N,42,40^FH
      ^FD\D1\D6\A7\0A\05^FS
      ^BY2,3,65^FT158,1339^BCN,,Y,N
      ^FD>;0130>6ND->5000102>63IH^FS
      ^BY2,3,65^FT672,1237^BCN,,Y,N
      ^FD>;0130>6ND->5000102>63IH^FS
      ^BY2,3,65^FT672,1134^BCN,,Y,N
      ^FD>;0130>6ND->5000102>63IH^FS
      ^BY2,3,65^FT672,1031^BCN,,Y,N
      ^FD>;0130>6ND->5000102>63IH^FS
      ^BY2,3,65^FT672,928^BCN,,Y,N
      ^FD>;0130>6ND->5000102>63IH^FS
      ^BY2,3,65^FT158,1237^BCN,,Y,N
      ^FD>;0130>6ND->5000102>63IH^FS
      ^BY2,3,65^FT158,1134^BCN,,Y,N
      ^FD>;0130>6ND->5000102>63IH^FS
      ^BY2,3,65^FT158,1031^BCN,,Y,N
      ^FD>;0130>6ND->5000102>63IH^FS
      ^BY2,3,65^FT158,928^BCN,,Y,N
      ^FD>;0130>6ND->5000102>63IH^FS
      ^BY3,3,65^FT194,578^BCN,,N,N
      ^FD>;0130>6ND->5000102>63IH^FS
      ^FT213,491^A0N,42,88^FH
      ^FD0000001C0001^FS
      ^PQ1,0,1,Y^XZ
    "
    s = TCPSocket.new(params[:printer_ip], '9100')
    s.write zpl_command
    s.close
  end

  def self.update_kcode(barcode, kcode)
    update_count = 0
    sql = "update txdb.phicomm_mes_001 set kcode='#{kcode}' where (sn='#{barcode}' or mac_add='#{barcode}')"
    begin
      update_count = PoReceipt.connection.execute(sql)
    rescue
    end
    update_count
  end

  def self.get_printer(pc_ip, program)
    # pc_ip
    # program
    # printer_ip
    # printer_port
    sql = "select printer_ip, printer_port from txdb.phicomm_mes_printer where pc_ip=? and program=?"
    records = PoReceipt.find_by_sql([sql, pc_ip, program])
    if records.present?
      return [records.first.printer_ip, records.first.printer_port]
    else
      sql = "insert into txdb.phicomm_mes_printer (pc_ip, program, printer_port) values ('#{pc_ip}','#{program}','9100')"
      PoReceipt.connection.execute(sql)
      return ['', '9100']
    end
  end

  def self.update_printer(pc_ip, program, printer_ip, printer_port = '9100')
    sql = "update txdb.phicomm_mes_printer set printer_ip='#{printer_ip}', printer_port='#{printer_port}' where pc_ip='#{pc_ip}' and program='#{program}'"
    PoReceipt.connection.execute(sql)
  end

end

