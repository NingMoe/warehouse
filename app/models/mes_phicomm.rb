﻿class MesPhicomm

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

  def self.sn_check_sn(barcode_sn)
    sql = "select sn from txdb.phicomm_mes_001 where sn=?"
    records = PoReceipt.find_by_sql([sql, barcode_sn])
    if records.present?
      sn = records.first.sn
    else
      sn = 'N/A'
    end
    sn
  end

  def self.check_kcode(barcode_sn, barcode_kcode)
    sql = "select sn,kcode,station from txdb.phicomm_mes_001 where sn=? and kcode=?"
    records = PoReceipt.find_by_sql([sql, barcode_sn, barcode_kcode])
    if records.present?
      return [records.first.sn,records.first.kcode,records.first.station]
    else
      return ['N/A', 'N/A', 'N/A']
    end
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
        ^FD#{mac_add}^FS
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
      ^LL0130
      ^LS0
      ^BY2,3,60^FT54,118^BCN,,N,N
      ^FD#{sn}^FS
      ^FT103,40^A0N,25,24^FH\^FD#{sn}^FS
      ^FT55,40^A0N,25,24^FH\^FDSN:^FS
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
      ^BY2,3,56^FT32,128^BCN,,N,N
      ^FD#{sn}^FS
      ^FT95,57^A0N,25,24^FH\^FD#{sn}^FS
      ^FT47,57^A0N,25,24^FH\^FDSN:^FS
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

  def self.print_color_box_a2(barcode_sn, printer_ip)
    sql = "select mac_add from txdb.phicomm_mes_001 where sn=?"
    records = PoReceipt.find_by_sql([sql, barcode_sn])
    if records.present?
      mac_add = records.first.mac_add
      print_color_box_label_a2(barcode_sn, printer_ip)
    else
      mac_add = 'N/A'
    end
    mac_add
  end

  def self.print_color_box_label_a2(sn, printer_ip)
    zpl_command = "
      ^XA~TA000~JSN^LT0^MNW^MTT^PON^PMN^LH0,0^PR4,4~SD28^JUS^LRN^CI0^XZ
      ^XA
      ^MMT
      ^PW1768
      ^LL0413
      ^LS0
      ^FT59,52
      ^A@N,30,30,E:ARIAL.TTF
      ^FH^FDS/N:#{sn}^FS
      ^BY2,3,72
      ^FT61,130^BCN,,N,Y
      ^FD#{sn}^FS
      ^FT59,162
      ^A@N,30,30,E:ARIAL.TTF
      ^FH^FDH/W Ver.:A2^FS
      ^PQ1,0,1,Y^XZ
    "
    s = TCPSocket.new(printer_ip, '9100')
    s.write zpl_command
    s.close
  end

  def self.print_color_box_label(sn, printer_ip)
    zpl_command = "
      ^XA~TA000~JSN^LT0^MNW^MTT^PON^PMN^LH0,0^PR4,4~SD28^JUS^LRN^CI0^XZ
      ^XA
      ^MMT
      ^PW1768
      ^LL0413
      ^LS0
      ^FT59,52
      ^A@N,30,30,E:ARIAL.TTF
      ^FH^FDS/N:#{sn}^FS
      ^BY2,3,72
      ^FT61,130^BCN,,N,Y
      ^FD#{sn}^FS
      ^FT59,162
      ^A@N,30,30,E:ARIAL.TTF
      ^FH^FDH/W Ver.:A1^FS
      ^PQ1,0,1,Y^XZ
    "
    s = TCPSocket.new(printer_ip, '9100')
    s.write zpl_command
    s.close
  end
  
  def self.mac_print_sn(barcode_sn, printer_ip)
    sql = "select sn from txdb.phicomm_mes_001 where sn=?"
    records = PoReceipt.find_by_sql([sql, barcode_sn])
    if records.present?
      mac_add = records.first.sn
      #mac_print_sn_label(records.first.sn, printer_ip)
    else
      mac_add = 'N/A'
    end
    mac_add
  end
  
  def self.mac_print_sn_label(sn, printer_ip)
    zpl_command = "
      ^XA~TA000~JSN^LT0^MNW^MTT^PON^PMN^LH0,0^PR4,4~SD28^JUS^LRN^CI0^XZ
      ^XA
      ^MMT
      ^PW1768
      ^LL0413
      ^LS0
      ^FT59,52
      ^A@N,30,30,E:ARIAL.TTF
      ^FH^FDS/N:#{sn}^FS
      ^BY2,3,72
      ^FT61,130^BCN,,N,Y
      ^FD#{sn}^FS
      ^FT59,162
      ^A@N,30,30,E:ARIAL.TTF
      ^FH^FDH/W Ver.:A1^FS
      ^PQ1,0,1,Y^XZ
    "
    s = TCPSocket.new(printer_ip, '9100')
    s.write zpl_command
    s.close
  end
  
  def self.print_nameplate_box(barcode_sn, printer_ip)
    sql = "select mac_add from txdb.phicomm_mes_001 where sn=?"
    records = PoReceipt.find_by_sql([sql, barcode_sn])
    if records.present?
      mac_add = records.first.mac_add
      print_nameplate_box_label(barcode_sn, printer_ip)
    else
      mac_add = 'N/A'
    end
    mac_add
  end

  def self.print_nameplate_box_label(sn, printer_ip)
    zpl_command = "
      ^XA~TA000~JSN^LT0^MNW^MTT^PON^PMN^LH0,0^PR4,4~SD30^JUS^LRN^CI0^XZ
      ^XA
      ^MMT
      ^PW1768
      ^LL0413
      ^LS0
      ^FT65,505
      ^A@N,40,40,E:ARIAL.TTF
      ^FH^FDS/N:#{sn}^FS
      ^BY3,3,78
      ^FT67,597^BCN,,N,Y
      ^FD#{sn}^FS
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

    sql = "select mac_add from txdb.phicomm_mes_001 where sn=? and cartonnumber is null"
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
        sql = "update txdb.phicomm_mes_001 set cartonnumber = '#{label_barcode}', partnumber = '#{params[:material_number]}', woid='#{params[:mo_number]}' ,cartonnumber_updated_dt = sysdate where station='90' and kcode is not null and mac_add is not null and sn in ('#{sn_array_text}')"
        PoReceipt.connection.execute sql
        #避免SN數組少於9個元素
        (sn_array.size..8).each {sn_array.append ''}

        # 打印标签
        print_outside_box_label(label_barcode, sn_array, params)
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
      	^XA~TA000~JSN^LT0^MNW^MTT^PON^PMN^LH0,0^PR4,4~SD28^JUS^LRN^CI0^XZ
	^XA^CI28
	~DG000.GRF,05760,060,
	,::::::::::::::::I0Q2L0I2O0I2J0I2M0P2K0N2M0H2R0I2H0I2R0H20,H01FPFK01FHFO07FFC001FHFK017FOFJ07FMFD0J01FF40O017FE007FF0P01FFC,H07FPFE80H03FHF80M0IFE007FHF80I0QFE0H03FOFE0I07FFE0O03FHFH0IFE0O0IFE,H07FQFC0H03FHFC0L01FHFE007FHFJ01FPFC0H07FPFJ07FHFP07FHFH0JFP0IFE,H0SFE0H03FHF80M0IFE007FHF80H07FPFE003FQFE0H07FHF80N0JFH0JF80M03FHFE,01FSFI03FHFC0L01FHFE007FHFJ0RF8007FRFI07FHFC0M01FIFH0JF80M03FHFE,01FSFC003FHF80M0IFE007FHF8001FQF800FSF8007FHFE0M03FIFH0JFC0M03FHFE,01FDFDFDFDFDFHFDC001FDFC0L01FDFC007DFD0H01FDFDFDFDFDFD001FFDFDFDFDFDFDFC007DFFE0M01FDFD00FDFFC0M05FDFC,03FKFJBJFE003FHF80L01FHFE007FHF8007FJFMBH03FJFJBKFE007FIFN07FIFH0JFE0M0JFE,01FIFC0J01FIFH03FHFC0L01FHFE007FHFI07FIFP03FIFL07FHFE007FIFN07FIFH0KFM01FIFE,01FIF80K0JF803FHF80M0IFE007FHF800FIFE0O07FHFE0K03FIFH07FIF80L0KF80FJF80K01FIFE,01FIFM07FHF803FHFC0L01FHFE007FHFI0JF80O07FHFC0K01FIFH07FIFC0K01FJFH0KF80K01FIFE,03FHFE0L03FHF803FHF80L01FHFE007FHF801FIF80O0JF80L0JF807FIFE0K03FJFH0KF80K03FIFE,01FHFC0L03FHFC03FHFC0L01FHFE007FHFH01FIFQ07FHFN07FHFH07FIFE0K03FJFH0KFC0K07FIFE,01FHFE0L03FHFC03FHF80M0IFE007FHF801FHFE0P0JF80L0JF807FJFL07FJFH0KFE0K0KFE,01FDFC0L01FDFC01FDFC0L01FDFC007DFD001DFDC0P0FDFD0M07DFD807DFDFD0K07DFDFD00FDFDFD0K0FDFDFC,03FHFE0L03FHFC03FHF80L01FHFE007FHF803FHFE0P0JFN07FHF807FJF80J0LFH0LF80I03FJFE,01FHFC0L03FHFC03FHFC0L01FHFE007FHFH01FHFC0P0JFN07FHF807FJFC0I01FKFH0LF80I03FJFE,03FHFE0L03FHFC03FHF80M0IFE007FHF803FHFE0P0IFE0M03FHF807FJFE0I03FKF80FKFC0I03FJFE,01FHFC0L01FHFC03FHFC0L01FHFE007FHFH01FHFC0P0JFN07FHF807FJFE0I03FKFH0LFC0I07FJFE,03FHFE0L03FHFC03FHFC0L01FHFE007FHF803FHFE0P0IFE0M03FHF807FKFJ07FKFH0LFE0I0LFE,01FHFC0L01FHFC03FHFC0L01FHFE007FHFH01FHFC0P0JFN07FHF807FKFJ07FKFH0MFI01FKFE,01FHFE0L03FHFC03FHFC0L03FHFE007FHF803FHFE0P0IFE0M03FHF807FHFBFF80H0HFEFIFH0JFBFF8001FFBFHFE,01FDFC0L01FDFC01FDFC0L01FDFC007DFF001DFDC0P0FDFD0M07DFD807DFD05FC001DF87DFD00FDFD1DF8001FF0FDFC,03FHFE0L03FHFC03FHFE0L03FHFE007FHF803FHFE0P0JFN03FHF807FHF87FE003FF0FIFH0JF0FFE007FE0FHFE,01FHFC0L01FHFC03FIFM07FHFE007FHFH01FHFC0P0JFN07FHF807FHF03FF007FE07FHFH0JF07FF01FFC1FHFE,01FHFE0L03FHFC03FIF80K0JFE007FHF803FHFE0P0IFE0M03FHF807FHF83FFEFHFE0FIF80FIF03FFEFHF80FHFE,01FHFC0L01FHFC03FIFC0J01FIFE007FHFH01FHFC0P0JFN07FHF807FHFH0HFDFHFC07FHFH0JF01FKF01FHFE,03FHFE0L03FHFC03FJFJABFJFE007FHF803FHFE0P0JFN03FHF807FHF80FKF80FIFH0JF01FKFH0IFE,01FHFC0L01FHFC03FTFE007FHFH01FHFC0P0JFN07FHF807FHFH07FJFH07FHFH0JFH0KFE01FHFE,01FHFE0L03FHFC03FTFE007FHF803FHFE0P0IFE0M03FHF807FHF803FIFE00FIFH0JFH0KFE00FHFE,01FDFC0L01FDFC01FDFDFDFDFDFDFDFC007DFD001DFDC0P0FDFD0M07DFD807DFD001DFDFC007DFD00FDFD007DFDFC00FDFC,03FHFE0L03FHFC03FTFE007FHF803FHFE0P0JFN03FHF807FHF803FIFE00FIFH0JFH03FIF800FHFE,01FHFC0L03FHFC03FTFE007FHFH01FHFC0P0JFN07FHF807FHFH01FIFC007FHFH0JFH01FIFH01FHFE,03FHFE0L03FHF803FTFE007FHF803FHFE0P0IFE0M03FHF807FHF800FIF800FIF80FIFI0JFI0IFE,01FIFM07FHF803FTFE007FHFH01FHFC0P0JFN07FHF807FHFI07FHFI07FHFH0JFI0IFE001FHFE,03FIF80K0JF803FJFKAKFE007FHF803FHFE0P0IFE0M03FHF807FHF8003FFE0H0JFH0JFI0IFE0H0IFE,01FIFC0J01FIFH03FIFC0J01FIFE007FHFH01FHFC0P0JFN07FHF807FHFI01FFC0H07FHFH0JFI07FFC001FHFE,01FJFEAHABFIFE003FIF80K0JFE007FHF803FHFE0P0IFE0M03FHF807FHF8001FFC0H0JFH0JFI03FF80H0IFE,01FDFHFDFDFDFHFDC001FDFD0L05FDFC007DFF001DFDC0P0FDFD0M07DFD807DFF0I0FD80H07DFD00FDFD0H01FD0I0FDFC,03FSFC003FHFE0L03FHFE007FHF803FHFE0P0JFN03FHF807FHF80H03F80H0JFH0JFJ0FE0I0IFE,01FSFI03FHFC0L01FHFE007FHFH01FHFC0P0JFN07FHF807FHFP07FHFH0JFO01FHFE,01FRFE0H03FHFC0L03FHFE007FHF803FHFE0P0IFE0M03FHF807FHF80N0JF80FIFP0IFE,01FQFDC0H03FHFC0L01FHFE007FHFH01FHFC0P0JFN07FHF807FHFP07FHFH0JFO01FHFE,03FQFE0I03FHFC0L01FHFE007FHF803FHFE0P0JFN03FHF807FHF80N0JFH0JFP0IFE,01FQFK03FHFC0L01FHFE007FHFH01FHFC0P0JFN07FHF807FHFP07FHFH0JFO01FHFE,01FJF808080L03FHF80M0IFE007FHF803FHFE0P0IFE0M03FHF807FHF80N0JFH0JFP0IFE,01FDFDC0Q01FDFC0L01FDFC007DFD001DFDC0P0FDFF0M07DFD807DFD0O07DFD00FDFD0O0FDFC,03FIF80Q03FHF80L01FHFE007FHF803FHFE0P0JFN07FHF807FHF80N0JFH0JFP0IFE,01FHFE0R03FHFC0L01FHFE007FHFH01FHFE0P0JFN07FHF807FHFP07FHFH0JFO01FHFE,03FHFE0R03FHF80M0IFE007FHF801FHFE0P0JF80L0JF807FHF80N0JF80FIFP0IFE,01FHFC0R03FHFC0L01FHFE007FHFH01FIFQ07FHF80L0JFH07FHFP07FHFH0JFO01FHFE,03FHFE0R03FHF80M0IFE007FHF801FIF80O0JF80K01FIF807FHF80N0JFH0JFP0IFE,01FHFC0R03FHFC0L01FHFE007FHFH01FIF80O07FHFC0K01FIFH07FHFP07FHFH0JFO01FHFE,01FHFE0R03FHF80M0IFE007FHF800FIFE0O07FHFE80J0JFE007FHF80N0JFH0JFP0IFE,01FDFC0R01FDFC0L01FDFC007DFF0H05FDFD0O03DFDFC0I01DFDFC007DFF0O07DFD00FDFD0O0FDFC,03FHFE0R03FHF80L01FHFE007FHF8007FQFH03FSFE007FHF80N0JFH0JFP0IFE,01FHFC0R03FHFC0L01FHFE007FHFI03FQFH01FSFC007FHFP07FHFH0JFO01FHFE,01FHFE0R03FHF80M0IFE007FHF8001FQF800FSF8007FHF80N0JF80FIFP0IFE,01FHFC0R03FHFC0L01FHFE007FHFJ07FPFC007DFPFE0H07FHFP07FDF00FIFO01FHFE,03FHFE0R03FHF80L01FHFE007FHF80H03FPFE003FQFE0H07FHF80N0JFH0JFP0IFE,01FHFC0R03FHFC0L01FHFE007FHFJ01FPFC0H07FPFJ07FHFP07FHFH0JFO01FHFE,01FHFC0R03FHF80M0IFE003FHF80I0BFOFE0H03FOFE0I03FHF80N0IFE00FHFE0O0IFE,H07DF0T07DF0N05DF0H01DFC0K05DFDFDFDFDF0I01FDFDFDFD40J01DFC0O01DFC001DFC0O05DF0,,::::::::::::::^XA
	^MMT
	^PW1228
	^LL1772
	^LS0
	^FT320,170^XG000.GRF,1,1^FS
	^FT800,145^A@N,65,65,E:ARIALYAHEI.TTF^FH\^FD斐讯^FS
	^FT277,265^A@N,58,58,E:ARIALYAHEI.TTF^FH\^FD四川斐讯信息技术有限公司^FS
	^FT95,350^A@N,42,40,E:ARIALYAHEI.TTF^FH\^FD型号：#{params[:model_number]}^FS
	^FT700,350^A@N,42,40,E:ARIALYAHEI.TTF^FH\^FD料号：#{params[:material_number]}^FS
	^FT95,465^A@N,42,40,E:ARIALYAHEI.TTF^FH\^FD箱号：^FS
	^BY2,3,72^FT233,500,E:ARIALYAHEI.TTF^BCN,,N,N^FD#{label_barcode}^FS
	^FT260,420^A@N,42,40,E:ARIALYAHEI.TTF^FH\^FD#{label_barcode}^FS
	^FT700,465^A@N,42,40,E:ARIALYAHEI.TTF^FH\^FD数量：#{params[:pack_qty]} pcs^FS
	^FT95,565^A@N,42,40,E:ARIALYAHEI.TTF^FH\^FD净重：#{params[:net_weight]}kg^FS
	^FT1000,565^A@N,42,40,E:ARIALYAHEI.TTF^FH\^FD中国 四川^FS
	^BY2,3,68^FT158,757^BCN,,Y,N^FD#{sn_array[0]}^FS
	^BY2,3,68^FT158,900^BCN,,Y,N^FD#{sn_array[2]}^FS
	^BY2,3,68^FT158,1043^BCN,,Y,N^FD#{sn_array[4]}^FS
	^BY2,3,68^FT158,1186^BCN,,Y,N^FD#{sn_array[6]}^FS
	^BY2,3,68^FT158,1329^BCN,,Y,N^FD#{sn_array[8]}^FS
	^BY2,3,68^FT690,757^BCN,,Y,N^FD#{sn_array[1]}^FS
	^BY2,3,68^FT690,900^BCN,,Y,N^FD#{sn_array[3]}^FS
	^BY2,3,68^FT690,1043^BCN,,Y,N^FD#{sn_array[5]}^FS
	^BY2,3,68^FT690,1186^BCN,,Y,N^FD#{sn_array[7]}^FS
	^PQ1,0,1,Y^XZ
    "
   s = TCPSocket.new(params[:printer_ip], '9100')
    s.write zpl_command
    s.close
  end

  def self.update_pallet(params)
    # params field
    # barcode
    # rowcounter
    # printer_ip
    # pack_qty
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
    # sn10
    # sn11
    # sn12
    # sn13
    # sn14
    # sn15
    # sn16
    error_msgs = []
    error_msgs.append "包裝數量不可為空!" if params[:pack_qty].blank?
    error_msgs.append "包裝栈板號不可為空!" if params[:carton_number].blank?
    error_msgs.append "掃入條碼不可為空!" if params[:barcode].blank?

    sn_array = []
    (1..16).each do |i|
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
        label_barcode = "PA#{carton_number.to_s.rjust(5, '0')}"
        sn_array_text = sn_array.join("','")
        sql = "update txdb.phicomm_mes_001 set palletnumber = '#{label_barcode}' where sn in ('#{sn_array_text}')"
        PoReceipt.connection.execute sql
        #避免SN數組少於16個元素
        (sn_array.size..16).each {sn_array.append ''}

        # 打印标签
        #update_pallet_label(label_barcode, palletnumber, params)
        carton_number += 1
        sn_array.clear
      end
    end
    (sn_array.size..16).each {sn_array.append ''}
    return [sn_array, error_msgs, mac_add, carton_number.to_s.rjust(5, '0')]
  end
  
  def self.update_pallet_label(label_barcode, palletnumber, params)
    update_count = 0
    sql = "update txdb.phicomm_mes_001 set palletnumber='#{palletnumber}' , cartonnumber_updated_dt = sysdate where sn='#{label_barcode}'"
    begin
      update_count = PoReceipt.connection.execute(sql)
    rescue
    end
    update_count
  end
  
  def self.update_kcode(barcode, kcode)
    update_count = 0
    sql = "update txdb.phicomm_mes_001 set kcode='#{kcode}',kcode_updated_dt = sysdate where (sn='#{barcode}' or mac_add='#{barcode}')"
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

  def self.get_next_stationname(stationid)
    sql = "SELECT STATION FROM PHICOMM_MES_STATION WHERE STATIONID = (SELECT MIN(STATIONID) FROM (SELECT STATIONID FROM PHICOMM_MES_STATION WHERE  STATIONID >= ?))"
    records = PoReceipt.find_by_sql([sql, stationid])
    if records.present?
      return records.first.STATION
    else
      return 'N/A'
    end
  end
  
  def self.get_barcode_station(barcode,stationid)
    sql = "select station from phicomm_mes_001 where sn = ? and station = ? "
    records = PoReceipt.find_by_sql([sql, barcode, stationid])
    if records.present?
      return records.first.STATION
    else
      return 'N/A'
    end
  end

  def self.checkRoute(sn, stationid)
    result = "error"
    cur_stationid = ""
    cur_stationname = ""
    next_stationid = ""
    next_stationname = ""
    sql = "with cur_station as (select a.sn, a.station,b.station station_name from txdb.phicomm_mes_001 a left join txdb.phicomm_mes_station b on b.stationid=a.station where a.sn= '#{sn}'), next_station as (  select min(stationid) stationid from txdb.phicomm_mes_station a where a.stationid > (select station from cur_station)) select a.sn, a.station,a.station_name, b.stationid next_stationid, c.station next_station_name from cur_station a, next_station b  left join txdb.phicomm_mes_station c on c.stationid = b.stationid "
    records = PoReceipt.find_by_sql(sql)
    if records.present?
      cur_stationid = records.first.station
      cur_stationname = records.first.station_name
      next_stationid = records.first.next_stationid
      next_stationname = records.first.next_station_name
      if cur_stationid.eql?(stationid)
        result = "ok"
      else
        result = "SN #{sn} 现在应该测试#{cur_stationname}站!"
      end
    end
  end

  def self.saveNextStation(sn, stationid)
    cur_stationid = ""
    cur_stationname = ""
    next_stationid = ""
    next_stationname = ""
    sql = "with cur_station as (select a.sn, a.station,b.station station_name from txdb.phicomm_mes_001 a left join txdb.phicomm_mes_station b on b.stationid=a.station where a.sn= ?), next_station as (  select min(stationid) stationid from txdb.phicomm_mes_station a where a.stationid > (select station from cur_station)) select a.sn, a.station,a.station_name, b.stationid next_stationid, c.station next_station_name from cur_station a, next_station b  left join txdb.phicomm_mes_station c on c.stationid = b.stationid "
    records = PoReceipt.find_by_sql([sql, sn])
    if records.present?
      cur_stationid = records.first.station
      cur_stationname = records.first.station_name
      next_stationid = records.first.next_stationid
      next_stationname = records.first.next_station_name
      if cur_stationid.eql?(stationid)
        updateStationBySn(sn, next_stationid)
      end
    end
  end

  def self.isExistStationByName(stationname)
    sql = "select stationid from txdb.phicomm_mes_station where station = ? "
    records = PoReceipt.find_by_sql([sql, stationname])
    if records.present?
      return true
    else
      return false
    end
  end

  def self.isExistSn(sn)
    sql = "select sn from txdb.v_phicomm_mes_001 where sn=?"
    records = PoReceipt.find_by_sql([sql, sn])
    if records.present?
      sn = records.first.sn
    else
      sn = 'N/A'
    end
    sn
  end

  def self.updateStationBySn(sn, stationname)
    sql = "update txdb.phicomm_mes_001 set station = '#{stationname}',station_up_dt = sysdate where sn = '#{sn}' "
    PoReceipt.connection.execute(sql)
  end
  
  def self.updateRework(sn,workid,stationid)
    sql = "update txdb.phicomm_mes_001 set station = '#{stationid}', pcname = '#{workid}',stime = sysdate where sn = '#{sn}' and dn_no is not null "
    PoReceipt.connection.execute(sql)
  end

  def self.rework_one()
    sql = "update txdb.phicomm_mes_001 set station = '80' where pcname = '30' and station = '40' and dn_no is not null "
    PoReceipt.connection.execute(sql)
  end

  def self.rework_two()
    sql = "update txdb.phicomm_mes_001 set cartonnumber = '', cartonnumber_updated_dt = sysdate  where pcname = '30' and dn_no is not null and station = '90' and cartonnumber like '1100%' "
    PoReceipt.connection.execute(sql)
  end

  def self.update_outside_box_label(cartonnumber)
    sql = "update txdb.phicomm_mes_001 set cartonnumber = '', cartonnumber_updated_dt = ''  where cartonnumber = '#{cartonnumber}' "
    PoReceipt.connection.execute(sql)
  end
  
  def self.test_log(sn, stationname,testitem,testvalue,testresult,stime,pcname,created_dt)
    sql = "insert into txdb.phicomm_mes_log(sn,station,testitem,testvalue,testresult,stime,pcname,created_dt) values('#{sn}','#{stationname}','#{testitem}','#{testvalue}','#{testresult}','#{stime}','#{pcname}',sysdate) "
    PoReceipt.connection.execute(sql)
  end  
  
  def self.testlum
    sn = "CBDEC2101K00474"
    net_weight = "18.10"
    pack_qty = "9"
    material_number = "911000053"
	model_number = "TC1"
    label_barcode = "1100112338C0001"
    zpl_command = "
	^XA~TA000~JSN^LT0^MNW^MTT^PON^PMN^LH0,0^PR4,4~SD28^JUS^LRN^CI0^XZ
	^XA^CI28
	~DG000.GRF,05760,060,
	,::::::::::::::::I0Q2L0I2O0I2J0I2M0P2K0N2M0H2R0I2H0I2R0H20,H01FPFK01FHFO07FFC001FHFK017FOFJ07FMFD0J01FF40O017FE007FF0P01FFC,H07FPFE80H03FHF80M0IFE007FHF80I0QFE0H03FOFE0I07FFE0O03FHFH0IFE0O0IFE,H07FQFC0H03FHFC0L01FHFE007FHFJ01FPFC0H07FPFJ07FHFP07FHFH0JFP0IFE,H0SFE0H03FHF80M0IFE007FHF80H07FPFE003FQFE0H07FHF80N0JFH0JF80M03FHFE,01FSFI03FHFC0L01FHFE007FHFJ0RF8007FRFI07FHFC0M01FIFH0JF80M03FHFE,01FSFC003FHF80M0IFE007FHF8001FQF800FSF8007FHFE0M03FIFH0JFC0M03FHFE,01FDFDFDFDFDFHFDC001FDFC0L01FDFC007DFD0H01FDFDFDFDFDFD001FFDFDFDFDFDFDFC007DFFE0M01FDFD00FDFFC0M05FDFC,03FKFJBJFE003FHF80L01FHFE007FHF8007FJFMBH03FJFJBKFE007FIFN07FIFH0JFE0M0JFE,01FIFC0J01FIFH03FHFC0L01FHFE007FHFI07FIFP03FIFL07FHFE007FIFN07FIFH0KFM01FIFE,01FIF80K0JF803FHF80M0IFE007FHF800FIFE0O07FHFE0K03FIFH07FIF80L0KF80FJF80K01FIFE,01FIFM07FHF803FHFC0L01FHFE007FHFI0JF80O07FHFC0K01FIFH07FIFC0K01FJFH0KF80K01FIFE,03FHFE0L03FHF803FHF80L01FHFE007FHF801FIF80O0JF80L0JF807FIFE0K03FJFH0KF80K03FIFE,01FHFC0L03FHFC03FHFC0L01FHFE007FHFH01FIFQ07FHFN07FHFH07FIFE0K03FJFH0KFC0K07FIFE,01FHFE0L03FHFC03FHF80M0IFE007FHF801FHFE0P0JF80L0JF807FJFL07FJFH0KFE0K0KFE,01FDFC0L01FDFC01FDFC0L01FDFC007DFD001DFDC0P0FDFD0M07DFD807DFDFD0K07DFDFD00FDFDFD0K0FDFDFC,03FHFE0L03FHFC03FHF80L01FHFE007FHF803FHFE0P0JFN07FHF807FJF80J0LFH0LF80I03FJFE,01FHFC0L03FHFC03FHFC0L01FHFE007FHFH01FHFC0P0JFN07FHF807FJFC0I01FKFH0LF80I03FJFE,03FHFE0L03FHFC03FHF80M0IFE007FHF803FHFE0P0IFE0M03FHF807FJFE0I03FKF80FKFC0I03FJFE,01FHFC0L01FHFC03FHFC0L01FHFE007FHFH01FHFC0P0JFN07FHF807FJFE0I03FKFH0LFC0I07FJFE,03FHFE0L03FHFC03FHFC0L01FHFE007FHF803FHFE0P0IFE0M03FHF807FKFJ07FKFH0LFE0I0LFE,01FHFC0L01FHFC03FHFC0L01FHFE007FHFH01FHFC0P0JFN07FHF807FKFJ07FKFH0MFI01FKFE,01FHFE0L03FHFC03FHFC0L03FHFE007FHF803FHFE0P0IFE0M03FHF807FHFBFF80H0HFEFIFH0JFBFF8001FFBFHFE,01FDFC0L01FDFC01FDFC0L01FDFC007DFF001DFDC0P0FDFD0M07DFD807DFD05FC001DF87DFD00FDFD1DF8001FF0FDFC,03FHFE0L03FHFC03FHFE0L03FHFE007FHF803FHFE0P0JFN03FHF807FHF87FE003FF0FIFH0JF0FFE007FE0FHFE,01FHFC0L01FHFC03FIFM07FHFE007FHFH01FHFC0P0JFN07FHF807FHF03FF007FE07FHFH0JF07FF01FFC1FHFE,01FHFE0L03FHFC03FIF80K0JFE007FHF803FHFE0P0IFE0M03FHF807FHF83FFEFHFE0FIF80FIF03FFEFHF80FHFE,01FHFC0L01FHFC03FIFC0J01FIFE007FHFH01FHFC0P0JFN07FHF807FHFH0HFDFHFC07FHFH0JF01FKF01FHFE,03FHFE0L03FHFC03FJFJABFJFE007FHF803FHFE0P0JFN03FHF807FHF80FKF80FIFH0JF01FKFH0IFE,01FHFC0L01FHFC03FTFE007FHFH01FHFC0P0JFN07FHF807FHFH07FJFH07FHFH0JFH0KFE01FHFE,01FHFE0L03FHFC03FTFE007FHF803FHFE0P0IFE0M03FHF807FHF803FIFE00FIFH0JFH0KFE00FHFE,01FDFC0L01FDFC01FDFDFDFDFDFDFDFC007DFD001DFDC0P0FDFD0M07DFD807DFD001DFDFC007DFD00FDFD007DFDFC00FDFC,03FHFE0L03FHFC03FTFE007FHF803FHFE0P0JFN03FHF807FHF803FIFE00FIFH0JFH03FIF800FHFE,01FHFC0L03FHFC03FTFE007FHFH01FHFC0P0JFN07FHF807FHFH01FIFC007FHFH0JFH01FIFH01FHFE,03FHFE0L03FHF803FTFE007FHF803FHFE0P0IFE0M03FHF807FHF800FIF800FIF80FIFI0JFI0IFE,01FIFM07FHF803FTFE007FHFH01FHFC0P0JFN07FHF807FHFI07FHFI07FHFH0JFI0IFE001FHFE,03FIF80K0JF803FJFKAKFE007FHF803FHFE0P0IFE0M03FHF807FHF8003FFE0H0JFH0JFI0IFE0H0IFE,01FIFC0J01FIFH03FIFC0J01FIFE007FHFH01FHFC0P0JFN07FHF807FHFI01FFC0H07FHFH0JFI07FFC001FHFE,01FJFEAHABFIFE003FIF80K0JFE007FHF803FHFE0P0IFE0M03FHF807FHF8001FFC0H0JFH0JFI03FF80H0IFE,01FDFHFDFDFDFHFDC001FDFD0L05FDFC007DFF001DFDC0P0FDFD0M07DFD807DFF0I0FD80H07DFD00FDFD0H01FD0I0FDFC,03FSFC003FHFE0L03FHFE007FHF803FHFE0P0JFN03FHF807FHF80H03F80H0JFH0JFJ0FE0I0IFE,01FSFI03FHFC0L01FHFE007FHFH01FHFC0P0JFN07FHF807FHFP07FHFH0JFO01FHFE,01FRFE0H03FHFC0L03FHFE007FHF803FHFE0P0IFE0M03FHF807FHF80N0JF80FIFP0IFE,01FQFDC0H03FHFC0L01FHFE007FHFH01FHFC0P0JFN07FHF807FHFP07FHFH0JFO01FHFE,03FQFE0I03FHFC0L01FHFE007FHF803FHFE0P0JFN03FHF807FHF80N0JFH0JFP0IFE,01FQFK03FHFC0L01FHFE007FHFH01FHFC0P0JFN07FHF807FHFP07FHFH0JFO01FHFE,01FJF808080L03FHF80M0IFE007FHF803FHFE0P0IFE0M03FHF807FHF80N0JFH0JFP0IFE,01FDFDC0Q01FDFC0L01FDFC007DFD001DFDC0P0FDFF0M07DFD807DFD0O07DFD00FDFD0O0FDFC,03FIF80Q03FHF80L01FHFE007FHF803FHFE0P0JFN07FHF807FHF80N0JFH0JFP0IFE,01FHFE0R03FHFC0L01FHFE007FHFH01FHFE0P0JFN07FHF807FHFP07FHFH0JFO01FHFE,03FHFE0R03FHF80M0IFE007FHF801FHFE0P0JF80L0JF807FHF80N0JF80FIFP0IFE,01FHFC0R03FHFC0L01FHFE007FHFH01FIFQ07FHF80L0JFH07FHFP07FHFH0JFO01FHFE,03FHFE0R03FHF80M0IFE007FHF801FIF80O0JF80K01FIF807FHF80N0JFH0JFP0IFE,01FHFC0R03FHFC0L01FHFE007FHFH01FIF80O07FHFC0K01FIFH07FHFP07FHFH0JFO01FHFE,01FHFE0R03FHF80M0IFE007FHF800FIFE0O07FHFE80J0JFE007FHF80N0JFH0JFP0IFE,01FDFC0R01FDFC0L01FDFC007DFF0H05FDFD0O03DFDFC0I01DFDFC007DFF0O07DFD00FDFD0O0FDFC,03FHFE0R03FHF80L01FHFE007FHF8007FQFH03FSFE007FHF80N0JFH0JFP0IFE,01FHFC0R03FHFC0L01FHFE007FHFI03FQFH01FSFC007FHFP07FHFH0JFO01FHFE,01FHFE0R03FHF80M0IFE007FHF8001FQF800FSF8007FHF80N0JF80FIFP0IFE,01FHFC0R03FHFC0L01FHFE007FHFJ07FPFC007DFPFE0H07FHFP07FDF00FIFO01FHFE,03FHFE0R03FHF80L01FHFE007FHF80H03FPFE003FQFE0H07FHF80N0JFH0JFP0IFE,01FHFC0R03FHFC0L01FHFE007FHFJ01FPFC0H07FPFJ07FHFP07FHFH0JFO01FHFE,01FHFC0R03FHF80M0IFE003FHF80I0BFOFE0H03FOFE0I03FHF80N0IFE00FHFE0O0IFE,H07DF0T07DF0N05DF0H01DFC0K05DFDFDFDFDF0I01FDFDFDFD40J01DFC0O01DFC001DFC0O05DF0,,::::::::::::::^XA
	^MMT
	^PW1228
	^LL1772
	^LS0
	^FT320,170^XG000.GRF,1,1^FS
	^FT800,145^A@N,65,65,E:ARIALYAHEI.TTF^FH\^FD斐讯^FS
	^FT277,265^A@N,58,58,E:ARIALYAHEI.TTF^FH\^FD四川斐讯信息技术有限公司^FS
	^FT95,350^A@N,42,40,E:ARIALYAHEI.TTF^FH\^FD型号：#{model_number}^FS
	^FT700,350^A@N,42,40,E:ARIALYAHEI.TTF^FH\^FD料号：#{material_number}^FS
	^FT95,465^A@N,42,40,E:ARIALYAHEI.TTF^FH\^FD箱号：^FS
	^BY2,3,72^FT233,500,E:ARIALYAHEI.TTF^BCN,,N,N^FD#{label_barcode}^FS
	^FT260,420^A@N,42,40,E:ARIALYAHEI.TTF^FH\^FD#{label_barcode}^FS
	^FT700,465^A@N,42,40,E:ARIALYAHEI.TTF^FH\^FD数量：#{pack_qty} pcs^FS
	^FT95,565^A@N,42,40,E:ARIALYAHEI.TTF^FH\^FD净重：#{net_weight}kg^FS
	^FT1000,565^A@N,42,40,E:ARIALYAHEI.TTF^FH\^FD中国 四川^FS
	^BY2,3,68^FT158,757^BCN,,Y,N^FD#{sn}^FS
	^BY2,3,68^FT158,900^BCN,,Y,N^FD#{sn}^FS
	^BY2,3,68^FT158,1043^BCN,,Y,N^FD#{sn}^FS
	^BY2,3,68^FT158,1186^BCN,,Y,N^FD#{sn}^FS
	^BY2,3,68^FT158,1329^BCN,,Y,N^FD#{sn}^FS
	^BY2,3,68^FT690,757^BCN,,Y,N^FD#{sn}^FS
	^BY2,3,68^FT690,900^BCN,,Y,N^FD#{sn}^FS
	^BY2,3,68^FT690,1043^BCN,,Y,N^FD#{sn}^FS
	^BY2,3,68^FT690,1186^BCN,,Y,N^FD#{sn}^FS
	^PQ1,0,1,Y^XZ
"
    s = TCPSocket.new('172.91.39.43', '9100')
    s.write zpl_command
    s.close
  end
	

  def self.felixtest
    sn = "CBDEC2101K00474"  
    zpl_command = "
      ^XA~TA000~JSN^LT0^MNW^MTT^PON^PMN^LH0,0^PR4,4~SD30^JUS^LRN^CI0^XZ
      ^XA
      ^MMT
      ^PW1768
      ^LL0413
      ^LS0
      ^FT60,505
      ^A@N,40,40,E:ARIAL.TTF
      ^FH^FDS/N:#{sn}^FS
      ^BY3,3,78
      ^FT62,597^BCN,,N,Y
      ^FD#{sn}^FS
      ^PQ1,0,1,Y^XZ
    "
    s = TCPSocket.new('172.91.39.40', '9100')
    s.write zpl_command
    s.close
  end
  	
  def self.test_name
    sn = "CBDEC2101K00474"  
    zpl_command = "      
      ^XA~TA000~JSN^LT0^MNW^MTT^PON^PMN^LH0,0^PR4,4~SD30^JUS^LRN^CI0^XZ
      ^XA
      ^MMT
      ^PW1768
      ^LL0413
      ^LS0
      ^FT60,505
      ^A@N,40,40,E:ARIAL.TTF
      ^FH^FDS/N:#{sn}^FS
      ^BY3,3,78
      ^FT62,597^BCN,,N,Y
      ^FD#{sn}^FS
      ^PQ1,0,1,Y^XZ
    "
    s = TCPSocket.new('172.91.39.42', '9100')
    s.write zpl_command
    s.close
  end

end

