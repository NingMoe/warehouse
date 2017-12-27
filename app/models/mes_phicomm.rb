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
      ^BY2,3,56^FT23,111^BCN,,N,N
      ^FD#{sn}^FS
      ^FT86,40^A0N,25,24^FH\^FD#{sn}^FS
      ^FT38,40^A0N,25,24^FH\^FDSN:^FS
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

  def self.print_color_box_label(sn, printer_ip)
    zpl_command = "
      ^XA~TA000~JSN^LT0^MNW^MTT^PON^PMN^LH0,0^JMA^PR4,4~SD15^JUS^LRN^CI0^XZ
      ^XA
      ^MMT
      ^PW531
      ^LL0177
      ^LS0
      ^BY2,3,56^FT76,137^BCN,,N,N
      ^FD#{sn}^FS
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
      ^XA~TA000~JSN^LT0^MNW^MTT^PON^PMN^LH0,0^JMA^PR4,4~SD15^JUS^LRN^CI0^XZ
      ^XA
      ^MMT
      ^PW768
      ^LL0413
      ^LS0
      ^FT93,239^A0N,22,19^FH\^FDS/N:^FS
      ^FT129,240^A0N,21,21^FH\^FD#{sn}^FS
      ^BY1,3,47^FT92,295^BCN,,N,N
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
        sql = "update txdb.phicomm_mes_001 set cartonnumber = '#{label_barcode}', woid='#{params[:mo_number]}' where sn in ('#{sn_array_text}')"
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
      ^XA~TA000~JSN^LT0^MNW^MTT^PON^PMN^LH0,0^JMA^PR4,4~SD15^JUS^LRN^CI0^XZ
~DG000.GRF,07680,080,
,:::::::::::::::::::::::::K03FOFA0J03FFA0M02FFE0H0HFE80I02BFNFE20H03FMFA0I027FE80O03FF803FFA20L0202FFE0O020H020H02,K07FPFD0I07FHFN07FHFH01FHF80I03FOFC0H03FOFC0H017FFC0N01FHF807FHFP07FFE0O0F001F,K0SF80H0JFN07FHF801FHF80H01FPFC003FPFE8001FHFE0N03FHF807FHF80N0IFE0O0F800E0N0E,J017FIFDFHFDFHFC0H05FHFN07FHFH01FHF80H01FPFC001FOFDF0H01FHFD0N07FHF807FHFP0IFE0O0F400E0M014,J03FSFI07FHFN07FHFH03FHFA0H0BFPF8003FQFE001FIF80M0JF807FHFA0M03FHFE0O0F800E0M03E807FLFE0,J01FSF8007FHFN07FHFH01FHF8001FQFH017FQFE001FIF80M0JF807FHFE0M07FHFE0J0K1F001F1I1J01F807FLFD0,J03FSFC00FIFN07FHF801FHF8003FPFE003FSF801FIFC0L02FIF807FHFE0M0JFE0J03FJF800FJFE0I0FE0FMFE0,J01FFDFC0J05FHFC007DFD0M07DFD001DFD8001FDFF0O03DFDF0J01DFHFC01FIFC0L03DFHF805FDFF0M0FDFFE0J03DFDFD0H0DFDFDE0I07E0H01D0H01C0,J03FHFEA0J02FIFH0JF020K07FHF803FHFA00BFHFE0O0JFE20J03FHFE01FJFM07FIF807FIFA0K03FIFE0J02AA2AF800EA2AHA20H03F8003E8003E0,J01FHFC0L07FHFH07FHFN07FHFH01FHF800FIFQ0JF80K01FHFE01FJFM07FIF807FIFC0K05FIFE0O0F001F0N01FC001F0H03D0,J03FHFC0L07FHF80FIFN07FHF801FHF800FIFQ0IFE80K01FHFE01FJF80K0KF807FIFE0K0KFE0O0F800E0O0FC001E8003E0,J01FHFC0L07FHF807FHFN07FHFH01FHF800FHFE0P0IFE0L017FFE01FJFC0J03FJF807FJFL0KFE0O0F400E0O070H01E0H03C0,J03FHFC0L07FHF807FHFN07FHFH03FHFA00FHFE0P0IFE0M0IFE01FKFK03FJF807FJF80J0KFE0J03FJF800FJFE0J020H03E8003E0,J01FHFC0L07FHF807FHFN07FHFH01FHF801FHFE0O01FHFE0M07FFE01FKFK07FJF807FJF80I01FJFE0J01FJFH01FJFC0N01F0H03D0,J03FHFC0L07FHF80FIFN07FHF801FHF800FHFE0P0IFE0M0IFE01FKF80I0LF807FJFE0I07FJFE0J01FJF800FJFC0N01E8003E0,J01DFDC0L07DFD807DFF0M07DFF001DFD800DFFE0P0FDFE0M07DFC01FDFDFFC0I0DFHFDF805FHFDFD0I07DFDFDE0O0D0H0E0S01C0H01C0,J03FHFC0L07FHF80FIF80L0JF803FHFA00FHFE0P0IFE0M0IFE01FKFE0H03FKF807FKF80H0LFE0O0F800E0P02003E8003E0,J01FHFC0L07FHF807FHF80L07FHFH01FHF801FHFE0O01FHFE0M07FFE01FHFD3FF0H07FD3FHF807FHF1FF8001FF1FHFE0O0F001F0S01F0H03D0,J03FHFC0L07FHF80FIF80L0JF801FHF800FHFE0P0IFE0M0IFE01FHFE0FF800FF83FHF807FHF8FFE007FE0FHFE0O0F800E80K01FFE0H01E8003E0,J01FHFC0L07FHF805FHFC0K01DFHFH01FHF800FHFE0P0IFE0M07FFE01FHFC07FC03FF03FHF807FHF01FF00FDC0FHFE0J0LFI0LF801FFE0H01E0H03C0,J03FHFC0L07FHF807FIF80J0KFH03FHFA00FHFE0P0IFE0M07FFE01FHFE03FKF03FHF807FHF80FKF80FHFE0J0LF800FKF801FFE0H03E8003E0,J01FHFC0L07FHF807FJFJ15FJFH01FHF801FHFE0O01FHFE0M07FFE01FHFD03FJFC03FHF807FHFH0LFH0IFE0J0K1F001F1H1010I01E0H01F0H03D0,J03FHFC0L07FHF80FUF801FHF800FHFE0P0IFE0M0IFE01FHFE00FJF803FHF807FHF80FJFE00FHFE0O0F8E0E0N01E1FLF3E0,J01DFFC0L07DFF807DFDFDFDFDFDFHFD001DFD800DFDE0P0FDFC0M07DFC01FDFC007DFDF001FHF805FHFH05FDFDC00DFDE0O0D1F0E0N01E1FDFDFDF1C0,J03FHFC0L07FHF80FUF803FHFA00FHFE0P0IFE0M0IFE01FHFE007FIFH03FHF807FHF803FIFA00FHFE0M020A0F0A0H02020H03E1FLF3E0,J01FHFC0L07FHFH07FTFH01FHF801FHFE0O01FHFE0M07FFE01FHFD003FHFC003FHF807FHFI0JFI0IFE0Q0F40O01E1I1F1H13D0,J03FHFC0L07FHF80FUF801FHF800FHFE0P0IFE0M0IFE01FHFE003FHFE003FHF807FHF800FIF800FHFE0Q0F80O01E0AABEAHA3E0,J01FHFC0L07FHFH07FTFH01FHF800FHFE0P0IFE0M07FFE01FHFC0H0IFC003FHF807FHFI07FHFI0IFE0Q0FC0O01E0H01E0H03C0,J03FIF80J02FIFH07FIFA2H202FJFH03FHFA00FHFE0P0IFE0M07FFE01FHFE002FHF8003FHF807FHF8003FFE0H0IFE0J0TFE80H03E0H03E8003E0,J01FJFJ017FHFC007FIFL05FIFH01FHF801FHFE0O01FHFE0M07FFE01FHFD0H07FF0H03FHF807FHFI01FF80H0IFE0J0UFJ01E0H01F0H03D0,J03FSF800FIFC0L0JF801FHF800FHFE0P0IFE0M0IFE01FHFE0H03FE0H03FHF807FHF80H0HF80H0IFE0J0TFE80H01E0H01E8003E0,J01DFDFHFDFDFDFDF0H07DFF80L0FDFF001DFD800DFFE0P0FDFE0M07DFE01FDFC0I070I01FDF805FDF0I05C0I0HFDE0M0FC0J01F80K01E0H01C0H01F0,J03FRFE0H0JF80L0JF803FHFA00FHFE0P0IFE0M0IFE01FHFE0N03FHF807FHFA0N0IFE0M0BE0I023E80K03E2003E8003F0,J01FRFJ07FHFN07FHFH01FHF801FHFE0O01FHFE0M07FFE01FHFD0N03FHF807FHFP0IFE0M01F0J07C0L01E0H01F0H03F0,J03FQF80I0JFN07FHF801FHF800FHFE0P0IFE0M0IFE01FHFE0N03FHF807FHF80N0IFE0N0FC0I0FC0L01E0H01E8002F0,J01FIFE0Q05FHFN07FHFH01FHF800FHFE0P0IFE0M07FFE01FHFC0N03FHF807FHFP0IFE0N07E0H01F80L01E0H01E0I0F03C,J03FIF80Q07FHFN07FHFH03FHFA00FHFE0P0IFE0M07FFE01FHFE0N03FHF807FHF80N0IFE0N03FA00FE0M03E0203E8002F83E,J01FHFC0R07FHFN07FHFH01FHF801FHFE0O01FHFE0L017FFE01FHFD0N03FHF807FHFP0IFE0N01FE01F40M01E0301F0I0F03C,J03FHFC0R0JFN07FHF801FHF800FHFE0P0IFE80K01FHFE01FHFE0N03FHF807FHF80N0IFE0O0BF8FE0N01E0F81E80H0F83C,J01DFDC0R07DFD0M07FFD001DFD800DFDF0P0FDFD80K01FHFC01FDFC0N01FHF805FDF0O0DFDE0O01FDFC0N01E1F81C0I0F83C,J03FHFC20L020I0JFN07FHF803FHFA00FIFA0O0JFC0K03FHFE01FHFE0N03FHF807FHF80N0IFE0P0BFF8020L03EFF83E80H0FA3E,J01FHFC0R07FHFN07FHFH01FHF8003FHFE0O03FHFC0K07FHFC01FHFD0N03FHF807FHFP0IFE0O01FHFC0N01FFC01F0I07878,J03FHFC0R0JFN07FHF801FHF8003FIFE8L8H03FIFA8I8BFIF801FHFE0N03FHF807FHF80N0IFE0O0KFE80L03FF801E80H0FC78,J01FHFC0R07FHFN07FHFH01FHF8001FQFH01FRFD801FHFC0N03FHF807FHFP0IFE0M01FHF07FHF40K03FC001E0I07F78,J03FHFC0R07FHFN07FHFH03FHFA0H0RF800FRFE001FHFE0N03FHF807FHF80N0IFE0K02BFHFA02BFIFA80H07F8003E80H03FF8,J01FHFC0R07FHFN07FHFH01FHF80H03FPFC003FQFC001FHFD0N03FHF807FHFP0IFE0I017FIF40I07FIF80H03E0H01F0I01FF8,J03FHFC0R0JFN07FHF801FHF80I0QFE0H0QFE8001FHFE0N03FHF807FHF80N0IFE0J0JF80K0BFFE80H03C0H01E80I0HF8,J01FHFC0R07DFD0M05DFF001FHFK01FDFDFDFDFDE0H015FDFDFDFHFK07DFC0N01FHFH05FDF0O0DFDC0J07DF0O05E0I010I01C0J07F0,K02A20S0H2A0O02A20H02A20K0H2A2A2AHA2A0I02A2AHA2A280J02AA0O02A2A0H0IAP02A20H0200BA0P0H2L02001E80I02E0,lH0340gG01F0J01D0,,:::::::::::::::::::~DG001.GRF,12288,096,
,:::::::::::::::::::::::::::::::::h0F801F0gI030J080P0180,gH0F80L01F0L0F801F0gI03E0H03C0P01F0O07C0J03E0P03E0Q0180,gH0F80L01F0L0F801F0K010V07E0H07C0P03E0O07C0J03E0P03E0080N03F0,gH0F80L01F0L0F801F0K0380U07C0H03E0P03E0O07C0J03E0P03E01C0N03E0gR060,gH0F8001F0H01F0L0F801F0K0FC03FMFL0FC0H01F0P07C0O07C0J03E0P03E03F0N03E0N07FIF1FLFM08003F0K03FQFE0,K07FQF80H0F8001F0H01F007FJF801FJFC07E03FMFL0F80H01F0P07C0O07C0J03E0P03E07F80M07C0N07FIF1FLFL01F003F0K03FQFE0,K07FQF80H0F8001F0H01F007FJF801FJFC03F03FMFL0F80I0F80K03FOFC0I07C0J03E0P03E01FC0M07C0N07FIF1FLFL01F801F80J03FQFE0,K07FQF80H0F8001F0H01F007FJF801FJFC01F83FMFK01F80I0E0L03FOFC0I07C0J03E0P03E00FF0M0F80N07FIF1FLFL03F001F80J03FQFE0,K07FQF80H0F8001F0H01F007FJF801FJFC00FC0H07C001F0J01F3FOFH03FOFC0I07C0J03E0P03E007F8007FRFE07C01F1F0I01F0K03F0H0FC0V03E0,K07FQF80H0F8001F0H01F0L0F801F0L07E0H07C001F0J03F3FOFH03FOFC0I07C0J03E0P03E001FC007FRFE07C03E1F0I01F0K07E0H0FC0V03E0,K07C003E01F0H0F80H0F8001F0H01F0L0F801F0L07F0H07C001F0J03E3FOFH03E0M07C0I07C01FMFE0L03E0H0F8007FRFE07C03E1F0I01F0K0FC0H07E0V03E0,K07C003E01F0H0F80H0F8001F0H01F0L0F801F0L03F8007C001F0J07E3FOFH03E0M07C0I07C01FMFE0L03E0H070H07FRFE07C03E1F0I01F0K0FC0H07E0V03E0,K07C003E01F0H0F80H0F8001F0H01F0L0F801F0L01F0H07C001F0J07C0R03E0M07C007FIF1FMFE0L03E0H020L03E0O07C07C1F0I01F0J01F80H03F0V03E0,K07C003E01F0H0F80H0F8001F0H01F003FJF801FJF80H0E0H07C001F0J0FC0R03E0M07C007FIF1FMFE0L03E0P07C0O07C07C1F0I01F0J03F0I01F80U03E0,K07C003E01F0H0F80H0F8001F0H01F003FJF801FJF80H040H07C001F0J0F80R03E0M07C007FIFJ03E0P03E0P0FC0O07C0781F0I01F0J07F0I01FC0U03E0,K07C003E01F0H0F80H0F8001F0H01F003FJF801FJF80L07C001F0I01F80R03FOFC007FIFJ03E0J0TF80I0F80O07C0F81F0I01F0J07E0J0FE0H01FPF83E0,K07C003E01F0H0F80H0F8001F0H01F003FJF801FJF80L07C001F0I01F80R03FOFC0I07C0J03E0J0TF80H01F80O07C0F81FLFK0FC0J07E0H01FPF83E0,K07C003E01F0H0F80H0F8001F0H01F0L0F801F0Q07C001F0I03F807FMFI03FOFC0I07C0J03E0J0TF80H03F0P07C1F01FLFJ01F80J03F0H01FPF83E0,K07C003E01F0H0F80H0F8001F0H01F0L0F801F0Q07C001F0I03F807FMFI03FOFC0I07C0J03E0J0TF80H07F0P07C1F01FLFJ03F80J03F8001FPF83E0,K07C003E01F0H0F80H0F8001F0H01F0L0F801F0Q07C001F0I07F807FMFI03E0M07C0I07C0J03E0P0HF80N07FNFI07C1E01FLFJ07F0K01FC0T03E0,K07C003E01F0H0F80H0F8001F0H01F0L0F801F0Q07C001F0I07F807FMFI03E0M07C0I07C0J03E0O01FFC0N0PFI07C3E01F0I01F0I0FE0L0HFU03E0,K07C003E01F0H0F80H0F8001F0H01F00FKF801FJFE3FFC0H07C001F0I0HF80R03E0M07C0I07C0J03E0O03FFC0M01FOFI07C3E01F0I01F0H01FC0L07F80S03E0,K07C003E01F0H0F80H0F8001F0H01F00FKF801FJFE3FFC0H07C001F0H01FF80R03E0M07C0I07C0J03E0O03FFE0M03FOFI07C3C01F0I01F0H03F80L03FC0S03E0,K07C007C01F0H0F80H0F8001F0H01F00FKF801FJFE3FFC0H07C001F0H01FF80R03FOFC0I07C03FLFE0L07BEF0M07F80K01F0H07C7C01F0I01F0H07F0N0HFT03E0,K07C007C01F0H0F80H0F8001F0H01F00FKF801FJFE3FFC0H07C001F0H03EF80R03FOFC0I07C03FLFE0L07BEF0M0HF80K01F0H07C7C01F0I01F0H0FE0H020J07F80R03E0,K07C007C01F0H0F80H0F8001F0H01F0L0F841F0L07C0H07C001F0H07EF80R03FOFC0I07C33FLFE0L0F3E780K01FF80K01F0H07C7E01F0I01F003FC0H0780I03FE0R03E0,K07C007C01F0H0F80H0F8001F0H01F0L0FBE1F0L07C3FKF9F0H0FCF807FMF8003FOFC0I07DF3FLFE0K01E3E3C0K03FF80K01F0H07C3F01F0I01F007F80H07E0I01FF007FLF8003E0,K07C007C01F0H0F80H0F8001F0H01F0L0F9E1F0L07C3FKF9F0H0F8F807FMF8003E0M07C0I07FF03E0I03E0K03E3E3C0K07FF80K01F0H07C1F01FLFH0HFJ0FC0J07E007FLF8003E0,K07C00FC01F0H0F80H0F8001F0H01F0M01F0N07C3FKF9F0H078F807FMF8003E0M07C0I07FF03E0I07C0K03C3E1E0K0FEF80K01F0H07C0F81FLFH07E0H01F80J03C007FLF8003E0,K07C00F801F0H0F80H0F8001F0H01F0N0F0N07C3FKF9F0H070F807FMF8003E0M07C0H07FFC01F0I07C0K07C3E1F0J03FCFOFI07C0F81FLFH03C0H01F80J018007FLF8003E0,K07C00F801F0H0F80H0F8001F0H01F0N0F80M07C0H07C001F0H060F80R03E0M07C003FHFH01F0I0780K0F83E0F80I07F8FOFI07C07C1FLFH0180H03F0O07C0J0F8003E0,K07C01F801F0H0F80H0F8001F0H01F00FSFE007C0H07C001F0J0F80R03FOFC00FHFC001F0I0F80J01F03E07C0I0FE0FOFI07C07C1F07801F0L07E0O07C0J0F8003E0,K07C03F001F800F8001F8001F0H01F00FSFE007C0H07C001F0J0F80R03FOFC00FHFC0H0F80H0F0K03F03E07E0H01FC0FOFI07C03E1F0780H040K07E0O07C0J0F8003E0,K07C07F001FHFEF8001F0H01F0H01F00FSFE007C0H07C001F0J0F80R03FOFC00FE7C0H0F8001F0K03E03E03E0I0F80F80K01F0H07C03E1F03C0H0E0K0FC0O07C0J0F8003E0,K07C0FE0H0IFEF8001F0H01F0H01F00FSFE007C0H07C001F0J0F80R03FOFC00F07C0H07C003E0K07C03E01F0I0700F80K01F0H07C03E1F03C001F0J01F80O07C0J0F8003E0,K07C1FC0H0IFEF8001F0H01F0H01F0J0FC0J03F0J07C0H07C001F0J0F80R03E0M07C00407C0H07E003E0K0F803E00F80H0200F80K01F0H07C03E1F03E007F80I01F0H020L07C0J0F8003E0,K07C3FC0H07FFCF8001F0H01F0H01F0J07E0J07E0J07C0H07C001F0J0F803FMFI03E0H040I07C0I07C0H03E007C0J01F803E00FC0K0F80K01F0H07C01E1F01E00FF0J03F0H0F0L07C0J0F8003E0,K07CFF80H01FFCF8001F0H01F0H01F0J03F0J0FC0J07C0H07C001F0J0F803FMFN0F0J040I07C0H03F00F80J03F003E007F0K0F80K01F0H07C01F1F01F03FC0J07E001F80K07C0J0F8003E0,K07DFF0M0F8001F0H01F0H01F0J03F80H01FC0J07C0H07C001F0J0F803FMFI080H01F80I0E0I07C0H01F81F80J07E003E003F80J0F80K01F0H07C01F1F00F87F80J07C0H0FC0K07C0J0F8003E0,K07CFC0M0F8003F0H01F0H01F0J01FC0H03F80J07C0H07C001F030H0F803FMFH01F07C0FE0H01F0I07C0I0F83F0K0FC003E001FC0J0F80K01F0H07C03F1F007DFE0K0F80H07E0K07C0J0F8003E0,K07C780M0F8003E0H01F0H01F0K0FE0H07F0K07C0H07C0H0F03E00F803E0J01F001F07C07F0I0F80H07C0I0FC7E0J01F8003E0H0FE0J0PFI07C03E1F007FFC0J01F80H03E0K07C0J0F8003E0,K07C30N0F8003E0H01F0H01F0K07F800FE0K07C0H07C0H0F83E00F803E0J01F001E07C03F80407C0H07C0I07EFC0J07F0H03E0H07F80I0PFI07C03E1F003FF0K03F0I03F0K07C0J0F8003E0,K07C0O0F8007E0H01F0H01F0K03FC01FC0K07C0407C0H0F83E00F803E0J01F003E07C01FC07C7E0H07C0I03FF80J0FE0H03E0H03FC0I0PFI07C07E1F001FC0K07E0I01F80J07FLF8003E0,K07C0O0F8007E0H01F0H01F0L0HF07F80K07C0C07C0H0F83E00F803E0J01F003E07C007C07C3F0H07C0I01FF0J01FC0H03E0H01FF0I0PFI07FHFE1F0H0F80K07C0J0FC0J07FLF8003E0,K07C0O0F8007C0H01F0H01F0L07F8FE0L07C3C07C0H0F83E00F803E0J01F007C07C00380FC1F8007C0J0FE0J03F80H03E0I0HFC0H0F80K01F0H07DFFC1F002FC0K0F80J07E0J07FLF8003E0,K07C0O0F800FC0H01F0H01F0L03FHFC0L07C7E07C0H0F83E00F803E0J01F007C07C00100F80FC007C0I01FF0J0HFJ03E0I07FE0H0F80K01F0H07DFF81F00E7F0J01F0K03E0J07FLF8003E0,K07C0O0F801F80H01F0H01F0M0IFN07DFE07C0H07C3C00F803E0J01F00F807C0J0F807C007C0I07FFC0H01FE0I03E0I03FC0H0F80K01F0H07DFE01F03E3F80I03F0K03F0J07C0N03E0,K07C0O0F801F80H01F0H01F0M07FF0M07FFC07C0H07C7C00F803E0J01F00F807C0J0F807E007C0I0IFE0H03FC0I03E0J0F80H0F80K01F0H07C0H01F0FE1FE0I0FE0H07FIF80I07C0N03E0,K07FQF803F0I01F0H01F0L03FIFM07FF007C0H07C7C00F803E0J01F01F807C0J0F8038007C0H03FCFF8001F80I03E0J070I0F80K01F0H07C0H01F3FE07F8001FOFC0I07C0N03E0,K07FQF807F0I01F0H01F0K01FJFE0K07FE007C0H03E7C00F803FMF01F007C0I01F8010H07C0H0HF83FC0H0E0J03E0J020I0F80K01F0H07C0H01FHFC03FE007FOFE0I07C0N07E0,K07FQF807E0I01F0H01F0J01FHF8FIFK0HF8007C0H03E7C00F803FMF03F007E0I07F0K07C003FE01FF80040J03E0O0F80K07F0H07C0H01FHFH01FF803FOFE0T07E0,K07FQF80FC0I01F0H01F0I01FHFC03FIFE0H0HFI07C0H03FFC00F803FMFH02003FLFL0FC00FFC007FE0M03E0O0F80H03FHFE0H07C0H03FFC0H07FE03FLFC03F0P03FIFE0,K07C0O0F81FC0I01F0H01F0H07FIFI07FJF01FE0H07C0H01FFC00F803FMFK03FKFE0I07FFC07FF0H01FFC0L03E0O0F80H03FHFE0H07C0H07FF0I03FC01FHFL03F80O03FIFC0,K07C0O0F83F80N01F01FJF80I0JFE00F80H07C0I0HF800F803E0J01F0J01FKFC0I07FFC1FFC0I0IFM03E0O0F80H03FHFC0H07C0H03FC0J0F801C0M01FC0O01FIFC0,K07C0O0F81F0O01F00FIFC0K0IFE0070I07C0I07F800F803E0J01F0K07FJFK07FF80FF0J03FE0L03E0O0F80H01FHFJ07C0H01F0K030R0F80O01FIF80,g0E0O01F00FHFC0M0HFC0020I07C0I03F0H0F803E0J01F0V03FF007C0K07C0L03E0O0F80H01FE0J07C0H01C0Y0F0P01FHFE,g040O01F007FC0O0380L07C0I01E0gQ03FE0020L0180L03E0O0F80P07C0I080Y04,gU0380,,:::::::::::::::::::::::::::::::::::~DG002.GRF,02688,028,
,::::::::::::::::::::::::N0E0,N0E0gR01C0J07,N0E0J03FMFC0W01C0J07,N0E0J03FMFC0L07FMFH01C00E007,:N0E0J0380K01C0L07FMFH01C00E007,N0E0J0380K01C0L0700E03807001C00E007,::J0NFE038FKF1C0L0700E03807001C00E007,::J0E0H0E0H0E038001C001C0L0700E03807001C00E007,::::J0E0H0E0H0E038001C001C0L0701C03807001C00E007,J0E0H0E0H0E0387FJF1C0L0701C03807001C00E007,::J0E0H0E0H0E038001C001C0L0703C03807001C00E007,J0NFE038001C401C0L0703803807001C00E007,J0NFE038001CE01C0L0707803C07001C00E007,J0NFE038001C701C0L070F003FF7001C00E007,J0E0H0E0H0E038001C381C0L071F001FF7003800E007,J0E0H0E0H0E038001C1C1C0L0H7E0H0HF7003800E007,N0E0J038001C081C0L07FC0J07003800E007,N0E0J038001C001C0L0H780J07003800E007,N0E0J039FKF9C0L0720K07003800E007,N0E0J039FKF9C0L070L07007800E007,N0E0J039FKF9C0L070L070070H0E007,N0E0J0380K01C0L070L0700F0H0E007,:N0E0J0380K01C0L070L0701E0H0E007,N0E0J0380K01C0L07FMF03E0H0E007,N0E0J03FMFC0L07FMF03C0H0E007,N0E0J03FMFC0L07FMF0780H0E007,N0E0J03FMFC0L070L070F80K07,N0E0J0380K01C0L070L07070L07,N0E0J0380K01C0V020L07,,:::::::::::::::::::::::::::::~DG003.GRF,01536,016,
,:::::::::::::::::::::::::::::::::::::::::O0E0H0E,O0E080E,M040E0E0E0I03FKFC,M0E0E1C1C0I03FKFC,M070E1C1C0I0380I01C,M078E381C0I0380I01C,M038E781C0I03FKFC,M03CE70380I03FKFC,M010E203FHFC0380I01C,O0E003FHFC0380I01C,L01FIFE7FHFC03FKFC,L01FIFE700E003FKFC,L01FIFE700E00380I01C00E0,N01E00F00E00380I01C01F0,N03E80F00E0P01F0,N0HFC1F01C0FOF1F0,M01EFE3F81C0FOF0E0,M03CEF3F81C,M078E39B81C,L01E0E1C381C003FKFC,L03C0E08383C003FKFC,L01830H01C38003803801C,N078001C38003803801C,N070H01C78003FKFC,L01FIF80E70H03FKFC,L01FIF80E70H03803801C,L01FIF80FF0H03803801C,M01C03807E0H03803801C,M03C07007E0H03FKFC,M0780F003C0H03FKFC,M07C0E007C0H03803801C00E0,M01F1C007E0K0380I01F0,N0HFC00FF0K0380I01F0,N03F801EF803FMFC1F0,N03FF03E7803FMFC0E0,N0IFC7C3C0J0380,M0HF879F81F0J0380,L03FE01BF00F8FOF0,L01F0H07E007CFOF0,L0180H03800380,Q010H01,,::::::::::::~DG004.GRF,01536,016,
,:::::::::::::::::::::::::O01C0I01C0,:O01C0I01C0H0MF8,:N041C20401C0H0MF8,N0E1C38701C0H0E0J038,N0E1C70F81C0H0E0J038,N061C707C1C0H0E0J038,N071CF01E1C0H0E0J038,N071CE00F1C0H0E0J038,N079CE0061C0H0E0J038,N039DE0041C0H0MF8,N021CC0H01C0H0MF80380O01C0I01C0H0MF807C0O01C00801C0H0E0J03807C0N0JF8E01C0H0E0J03807C0N0JF9F01C0Q0380N0JF87C1C0,O03C003E1C03FNFE0,O03C001F1C03FNFE0,O03C0H0E1C03FNFE0,O07D0H041C0H01C,O07F80H01C0H038,O0FDC0H01CF0038,O0HDE0H07FF0070,N01DCF03FIFH07FKF8,N01DC7BFIF8007FKF8,N039C3BFF9C0H07FKF8,N039C13C01C0N038,N071C0I01C0N038,N0F1C0I01C0N0380380N0E1C0I01C0N03007C0N041C0I01C0N03007C0N041C0I01C0N07007C0O01C0I01C0N0700380O01C0I01C0N0E0,O01C0I01C0J07FHFE0,O01C0I01C0J07FHFC0,O01C0I01C0J03FHF,O01C0I01C0,,:::::::::::::::::::::::::::::~DG005.GRF,01536,016,
,::::::::::::::::::::::::::::::::::::O0180,O03C0O01FHF0,O0780J07FMF0,K020H0780J07FMF0,K0F0H0JFI07FIF8,K07001FIFM070,K07801FIFM070,K03803C00E0L070,K03C07801C003FNFE,K01C0F8038003FNFE,K01E1F0070H03FNFE,L0F3E00E0M070,L0F7FKFL070J038,L043FKFH01FLFC07C,M017FJFH01FLFC07C,P03807001FLFC07C,P03807001C007001C038,P03807001C007001C0,:L043FLF01FLFC0,L073FLF01FLFC0,L0F3FLF01FLFC0,L0E0H03807001C007001C0,::K01C0H03807001FLFC0,:K01C0FKFH01FLFC0,K03C0FKFH01C007001C0,K0380FKFL070,K0380H038070K070J038,K0780H03807007FMF07C,K070I0380I07FMF07C,:K0F0I0380M070J038,K0E0I0380M070,K020I0780H03FNFE,N03FF80H03FNFE,N03FF0I03FNFE,N01FE0,,::::::::::::::::::~DG006.GRF,01536,016,
,:::::::::::::::::::::::::::::::::::::::::M0E0H0380,L01C0H0780,L01C0H0F0J0MF80,L0380H0F0J0MF80,L07FHF1FIFH0MF80,L07FHF1FIFH0E0J0380,L0JF3FIFH0E0J0380,K01E1007840I0E0J0380,K01C380F0F0I0E0J0380,K0381C1E0780H0E0J0380,K0781C1C01C0H0E0J0380,K0F1CE080080H0MF80,K021C40M0MF8038,L01C03FIFC00FLF807C,L01C03FIFC00E0J03807C,:L01C038001C0P038,K07FHF38001C0,K07FHF38001C3FNFE,:L03C03FIFC3FNFE,L03C03FIFC001C0,L03C03FIFC00380,L07D038001C00380,L07F838001C007,L0HFC38001C007FKF80,L0HDE38001C007FKF80,K01DCF3FIFC007FKF80,K039C7BFIFC0M0380,K039C33FIFC0M0380,K071C038001C0M038038,K0F1C038001C0M03007C,K0E1C038001C0M03007C,K041C038001C0M07007C,K041C038001C0M070038,L01C03FIFC0M0E,L01C03FIFC0I07FHFE,L01C03FIFC0I07FHFC,L01C038001C0I03FHF0,L01C038001C0,:,::::::::::::~DG007.GRF,01536,016,
,:::::::::::::::::::U0380,:M03FIFE003800FLF80,M03FIFE383800FLF80,:N0381C0383800E0J0380,:::::N0381C0383800FLF80,M0LF383800FLF8038,M0LF383800FLF807C,M0LF383800E0J03807C,N0381C0383800E0J03807C,N0381C038380P038,N0701C038380,N0701C0H0383FNFE,N0F01C0H0383FNFE,N0E01C0H0783FNFE,M01C01C01FF8001C0,M03C01C01FF0H0380,M0780I01FE0H0380,M010H0380K07,Q0380K07FKF80,:N0NFI07FKF80,N0NFO0380,:Q0380Q038038,Q0380Q03007C,:Q0380Q07007C,Q0380Q070038,Q0380Q0E,M0PFJ07FHFE,M0PFJ07FHFC,M0PFJ03FHF0,,::::::::::::::::::::::::::::::::::::^XA
^MMT
^PW1228
^LL1772
^LS0
^FT288,160^XG000.GRF,1,1^FS
^FT224,288^XG001.GRF,1,1^FS
^FT896,608^XG002.GRF,1,1^FS
^FT736,480^XG003.GRF,1,1^FS
^FT736,384^XG004.GRF,1,1^FS
^FT64,608^XG005.GRF,1,1^FS
^FT64,480^XG006.GRF,1,1^FS
^FT64,384^XG007.GRF,1,1^FS
^FT189,587^A0N,42,40^FH\^FD#{params[:net_weight]}kg^FS
^FT883,465^A0N,42,40^FH\^FD#{params[:pack_qty]}PCS^FS
^FT878,354^A0N,42,40^FH\^FD#{params[:material_number]}^FS
^FT197,351^A0N,42,40^FH\^FD#{params[:model_number]}^FS
^BY2,3,65^FT158,1168^BCN,,Y,N
^FD#{sn_array[0]}^FS
^BY2,3,65^FT672,1065^BCN,,Y,N
^FD#{sn_array[1]}^FS
^BY2,3,65^FT672,963^BCN,,Y,N
^FD#{sn_array[2]}^FS
^BY2,3,65^FT672,860^BCN,,Y,N
^FD#{sn_array[3]}^FS
^BY2,3,65^FT672,757^BCN,,Y,N
^FD#{sn_array[4]}^FS
^BY2,3,65^FT158,1065^BCN,,Y,N
^FD#{sn_array[5]}^FS
^BY2,3,65^FT158,963^BCN,,Y,N
^FD#{sn_array[6]}^FS
^BY2,3,65^FT158,860^BCN,,Y,N
^FD#{sn_array[7]}^FS
^BY2,3,65^FT158,757^BCN,,Y,N
^FD#{sn_array[8]}^FS
^BY2,3,65^FT194,523^BCN,,N,N
^FD#{label_barcode}^FS
^FT192,420^A0N,42,40^FH\^FD#{label_barcode}^FS
^PQ1,0,1,Y^XZ
^XA^ID000.GRF^FS^XZ
^XA^ID001.GRF^FS^XZ
^XA^ID002.GRF^FS^XZ
^XA^ID003.GRF^FS^XZ
^XA^ID004.GRF^FS^XZ
^XA^ID005.GRF^FS^XZ
^XA^ID006.GRF^FS^XZ
^XA^ID007.GRF^FS^XZ
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

  def self.get_next_stationname(stationid)
    sql = "SELECT STATION FROM PHICOMM_MES_STATION WHERE STATIONID = (SELECT MIN(STATIONID) FROM (SELECT STATIONID FROM PHICOMM_MES_STATION WHERE  STATIONID >= ?))"
    records = PoReceipt.find_by_sql([sql, stationid])
    if records.present?
      return records.first.STATION
    else
      return 'N/A'
    end
  end

  def self.checkRoute(sn, stationid)
    # cur_stationid
    # cur_stationname
    # next_stationid
    # next_stationname
    sql = "with cur_station as (select a.sn, a.station,b.station station_name from txdb.phicomm_mes_001 a left join txdb.phicomm_mes_station b on b.stationid=a.station where a.sn= ?), next_station as (  select min(stationid) stationid from txdb.phicomm_mes_station a where a.stationid > (select station from cur_station)) select a.sn, a.station,a.station_name, b.stationid next_stationid, c.station next_station_name from cur_station a, next_station b  left join txdb.phicomm_mes_station c on c.stationid = b.stationid "
    records = PoReceipt.find_by_sql([sql, stationname])
    if records.present?
      cur_stationid = records.first.STATION
      cur_stationname = records.first.STATION_NAME
      next_stationid = records.first.NEXT_STATIONID
      next_stationname = records.first.NEXT_STATION_NAME
      if cur_stationid.eql?(stationid)
        return 'PASS'
      end
    else
      return "SN:'#{sn}'  现在应该测试'#{next_stationname}'站!"
    end
  end

  def self.saveNextStation(sn, stationname)
    sql = "SELECT ST.STATION, ST.STATIONID FROM PHICOMM_MES_STATION ST,PHICOMM_MES_001 MES WHERE ST.STATIONID = MES.STATION AND MES.SN = ?"
    records = PoReceipt.find_by_sql([sql, sn])
    if records.present?
      if records.first.STATION.eql?(stationname)
        updateStationBySn(sn, get_next_stationname(records.first.STATIONID))
        return 'PASS'
      end
    else
      return 'N/A'
    end
  end

  def self.isExistStationByName(stationname)
    sql = "select stationid from phicomm_mes_station where station = ? "
    records = PoReceipt.find_by_sql([sql, stationname])
    if records.present?
      return true
    else
      return false
    end
  end

  def self.updateStationBySn(sn, stationname)
    sql = "update txdb.phicomm_mes_001 set station = '#{stationname}',station_up_dt = sysdate where sn = '#{sn}'"
    PoReceipt.connection.execute(sql)
  end
end

