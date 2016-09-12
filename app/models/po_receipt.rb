class PoReceipt < ActiveRecord::Base
  self.primary_key = :uuid

  def self.barcode_present?(barcode)
    PoReceipt.select('uuid').find_by_barcode(barcode).present?
  end

  def self.barcode_content(barcode)
    contents = {}
    barcode = "@#{barcode}" if barcode[0] != '@'
    buf = barcode.split("@")
    return contents[:errors] = '格式錯誤 Format Error' if buf.size < 10
    return contents[:errors] = '數量錯誤 Qty Error' if buf[7].to_f == 0.0
    Date.parse(buf[6]) rescue return contents[:errors] = '製造日期錯誤 MfgDate Error'

    contents[:matnr] = buf[1].gsub(' ', '').upcase
    contents[:werks] = buf[2].gsub(' ', '').upcase
    contents[:lifnr] = buf[3].gsub(' ', '').upcase
    contents[:lifdn] = buf[4].gsub(' ', '').upcase
    contents[:date_code] = buf[5].gsub(' ', '')[0..14].upcase
    contents[:mfg_date] = buf[6]
    contents[:menge] = buf[7]
    contents[:pkg_no] = buf[8]

    return contents[:errors] = '料號錯誤 Material Error' if contents[:matnr].size == 0
    return contents[:errors] = '工廠錯誤 Plant Error' if contents[:werks].size == 0
    return contents[:errors] = '供應商錯誤 Supplier Error' if contents[:lifnr].size == 0
    return contents[:errors] = 'DN錯誤 DN Error' if contents[:lifdn].size == 0
    return contents[:errors] = 'DCode錯誤 DCode Error' if contents[:date_code].size == 0

    contents
  end

  def self.allocate_po(lifnr, lifdn, werks)
    sql = "
      with
        tmpa as (
          select matnr,sum(balqty)balqty, count(matnr)pkgqty
            from po_receipt a
            where a.status='10' and lifnr='#{lifnr}' and lifdn='#{lifdn}' and werks='#{werks}'
            group by matnr),
        tmpb as (
          select /*+driving_site(b)*/
            c.matnr,b.bedat,c.ebeln,c.ebelp,c.bstae,d.parvw,c.netpr,c.peinh, c.meins,
            (select sum(menge-wemng) from sapsr3.eket@sapp x where x.mandt='168' and x.ebeln=c.ebeln and x.ebelp= c.ebelp) eket,
            (select sum(menge-dabmg) from sapsr3.ekes@sapp y where y.mandt='168' and y.ebeln=c.ebeln and y.ebelp= c.ebelp) ekes
          from tmpa a
              join sapsr3.ekko@sapp b on b.mandt='168' and b.lifnr='#{lifnr}' and b.bsart not in ('Z006','Z007','Z008')
              join sapsr3.ekpo@sapp c on c.mandt='168' and c.ebeln=b.ebeln and c.loekz=' ' and c.elikz=' ' and c.matnr=a.matnr and c.werks='#{werks}'
              left join sapsr3.ekpa@sapp d on d.mandt='168' and d.ebeln=b.ebeln and d.ebelp='00000' and d.parza='001' and substr(d.parvw,1,1)='V'
        )
        select a.matnr,a.balqty,b.ebeln,b.ebelp,b.parvw,a.pkgqty,b.netpr,b.peinh,b.meins,
               nvl(b.eket,0)eket, nvl(b.ekes,0)ekes,
               case
                 when b.bstae = ' ' then b.eket
                 when b.ekes >= b.eket then b.eket
                 else nvl(b.ekes,0)
               end opnqty,
               nvl((select sum(alloc_qty) from po_receipt_line x where x.status='20' and x.ebeln=b.ebeln and x.ebelp=b.ebelp),0) xalcqty
          from tmpa a
            left join tmpb b on b.matnr=a.matnr
          order by a.matnr,b.bedat
        "
    # matnr	        balqty	ebeln	      ebelp	parvw	eket	ekes	opnqty	xalcqty
    # 1501005620000	 23436	8001232172	00240	V3	  9,682	0	    9,682	  0
    # 1501005620000	 23436	8001233769	00130	V3	  7,500	0	    7,500	  0
    # 1501005620000	 23436	8001233769	00140	V3	  900	  0	    900	    0
    list = PoReceipt.find_by_sql(sql)
    mats = {}
    pos = {}
    invalid_vtypes = %w[V1 V4]
    list.each do |pol|
      mats[pol.matnr] = {balqty: pol.balqty, alcqty: 0, opnqty: 0, xalcqty: 0, pkgqty: pol.pkgqty} unless mats.key?(pol.matnr)
      mat = mats[pol.matnr]
      if not invalid_vtypes.include?(pol.parvw)
        mat[:opnqty] += pol.opnqty
        mat[:xalcqty] += pol.xalcqty
        if mat[:balqty] > 0 and (pol.opnqty - pol.xalcqty) > 0
          pol_key = "#{pol.ebeln}.#{pol.ebelp}"
          pos[pol_key] = {alcqty: 0, matnr: pol.matnr, netpr: pol.netpr, peinh: pol.peinh, meins: pol.meins} unless pos.key?(pol_key)
          po = pos[pol_key]
          if mat[:balqty] > (pol.opnqty - pol.xalcqty)
            po[:alcqty] += (pol.opnqty - pol.xalcqty)
            mat[:balqty] -= (pol.opnqty - pol.xalcqty)
            mat[:alcqty] += (pol.opnqty - pol.xalcqty)
          else
            po[:alcqty] += mat[:balqty]
            mat[:alcqty] += mat[:balqty]
            mat[:balqty] -= mat[:balqty]
          end
        end
      end
    end
    return mats, pos
    # [{"1501005620000"=>{:balqty=>#<BigDecimal:984de01,'0.0',1(4)>, :alcqty=>#<BigDecimal:58cda03f,'23436.0',5(12)>, :opnqty=>45944, :xalcqty=>0}},
    #                         {"8001232172.00240"=>{:alcqty=>9682, :matnr=>"1501005620000"},
    #                          "8001233769.00130"=>{:alcqty=>7500, :matnr=>"1501005620000"},
    #                          "8001233769.00140"=>{:alcqty=>900, :matnr=>"1501005620000"},
    #                          "8001234069.00110"=>{:alcqty=>5100, :matnr=>"1501005620000"},
    #                          "8001235791.00070"=>{:alcqty=>#<BigDecimal:71ad959b,'254.0',3(12)>, :matnr=>"1501005620000"}}]
  end

  def self.direct_import_cfm_allocation(params)
    bukrs = params[:bukrs]
    dpseq = params[:dpseq]
    user = params[:user]
    params[:keys].each do |key|
      buf = key.split('_')
      matnr = buf[0]
      lifnr = buf[1]
      PoReceipt.transaction do
        receipts = PoReceipt.where(status: '10', bukrs: bukrs, dpseq: dpseq,
                                   matnr: matnr, lifnr: lifnr)
        ziebi002s = Ziebi002.where(status: '10', bukrs: bukrs, dpseq: dpseq,
                                   matnr: matnr, lifnr: lifnr)

        receipts.each do |receipt|
          ziebi002s.select{|c| c.balqty > 0}.each do |ziebi002|
            trans_qty = (receipt.balqty > ziebi002.balqty) ? ziebi002.balqty : receipt.balqty
            receipt.alloc_qty += trans_qty
            receipt.balqty -= trans_qty
            ziebi002.alloc_qty += trans_qty
            ziebi002.balqty -= trans_qty
            PoReceiptLine.create(
                po_receipt_id: receipt.uuid, status: '20', ebeln: ziebi002.ebeln, ebelp: ziebi002.ebelp,
                netpr: ziebi002.netpr, peinh: ziebi002.peinh, alloc_qty: trans_qty, charg: receipt.charg,
                impnr: ziebi002.impnr, impim: ziebi002.impim, invnr: ziebi002.invnr,
                creator: user, updater: user, meins: ziebi002.meins
            )
            ziebi002.status = '20' if ziebi002.balqty == 0
            ziebi002.updater = user
            ziebi002.save
            break if receipt.balqty == 0
          end
          receipt.status = '20'
          receipt.updater = user
          receipt.save
        end
      end
    end
  end

  def self.cfm_allocation(params)
    mats = {}
    params.each do |key, value|
      if key[0..1].eql?('po')
        buf = key.split('_')
        mats[buf[1]] = [] unless mats.key?(buf[1])
        value_buf = value.split('_')
        array = mats[buf[1]]
        array << {ebeln: buf[2], balqty: BigDecimal(value_buf[0]), alcqty: 0, netpr: BigDecimal(value_buf[1]), peinh: BigDecimal(value_buf[2]), meins: value_buf[3]}
      end
    end
    PoReceipt.transaction do
      receipts = PoReceipt.where(status: '10', lifnr: params[:lifnr], lifdn: params[:lifdn], werks: params[:werks]).order(:matnr)
      receipts.each do |receipt|
        pos = mats[receipt.matnr]
        pos.each do |hash|
          if hash[:balqty] > 0
            ebeln_buf = hash[:ebeln].split('.')
            if receipt.balqty > hash[:balqty]
              trans_qty = hash[:balqty]
              receipt.alloc_qty += trans_qty
              receipt.balqty -= trans_qty
              hash[:alcqty] += trans_qty
              hash[:balqty] -= trans_qty
            else
              trans_qty = receipt.balqty
              hash[:alcqty] += trans_qty
              hash[:balqty] -= trans_qty
              receipt.alloc_qty += trans_qty
              receipt.balqty -= trans_qty
            end
            PoReceiptLine.create(
                po_receipt_id: receipt.uuid, status: '20', ebeln: ebeln_buf[0], ebelp: ebeln_buf[1],
                netpr: hash[:netpr], peinh: hash[:peinh], alloc_qty: trans_qty, charg: receipt.charg,
                creator: params[:user], updater: params[:user], meins: hash[:meins]
            )
          end
          break if receipt.balqty == 0
        end
        receipt.status = '20'
        receipt.updater = params[:user]
        receipt.save
      end
    end
  end

  def self.sap_posting
    sql = "
      select a.lifnr,a.lifdn,a.werks,nvl(b.invnr,' ')invnr
        from po_receipt a
          join po_receipt_line b on b.po_receipt_id = a.uuid
        where a.status='20' and a.rfc_sts <> 'E' and b.status = '20'
        group by a.lifnr,a.lifdn,a.werks,nvl(b.invnr,' ')
    "
    dlv_notes = PoReceipt.find_by_sql(sql)
    dlv_notes.each do |dlv_note|
      dest = JCoDestinationManager.getDestination('sap_prd')
      repos = dest.getRepository
      commit = repos.getFunction('BAPI_TRANSACTION_COMMIT')
      commit.getImportParameterList().setValue('WAIT', 'X')
      #rollback = repos.getFunction('BAPI_TRANSACTION_ROLLBACK')

      function = repos.getFunction('BAPI_GOODSMVT_CREATE')
      function.getImportParameterList().getStructure('GOODSMVT_CODE').setValue('GM_CODE', '01')

      header = function.getImportParameterList().getStructure('GOODSMVT_HEADER')
      header.setValue('PSTNG_DATE', Date.today.strftime('%Y%m%d'));
      header.setValue('DOC_DATE', Date.today.strftime('%Y%m%d'));
      if dlv_note.invnr.present?
        header.setValue('BILL_OF_LADING', dlv_note.invnr)
      else
        header.setValue('BILL_OF_LADING', dlv_note.lifdn)
      end
      header.setValue('REF_DOC_NO', dlv_note.lifdn);
      header.setValue('PR_UNAME', 'LUM.LIN');
      header.setValue('HEADER_TXT', dlv_note.lifdn);

      lines = function.getTableParameterList().getTable('GOODSMVT_ITEM')
      sql = "
        select a.lifnr,a.lifdn,a.matnr,a.werks,a.charg,a.date_code,a.mfg_date,a.entry_date,
               b.ebeln,b.ebelp,
               sum(b.alloc_qty) alloc_qty,b.meins,
               b.impnr,b.impim,b.invnr
          from po_receipt a
            join po_receipt_line b on b.po_receipt_id = a.uuid
          where a.status='20' and b.status='20' and a.lifnr = ? and a.lifdn = ?
            and a.werks=? and nvl(b.invnr,' ') = ?
          group by a.lifnr,a.lifdn,a.matnr,a.werks,a.charg,a.date_code,a.mfg_date,a.entry_date,
                   b.ebeln,b.ebelp,b.impnr,b.impim,b.invnr,b.meins
      "
      pos = PoReceipt.find_by_sql([sql, dlv_note.lifnr, dlv_note.lifdn, dlv_note.werks, dlv_note.invnr])
      pos.each do |po|
        lines.appendRow()
        lines.setValue('MATERIAL', po.matnr)
        lines.setValue('PLANT', po.werks)
        #lines.setValue("STGE_LOC", m.get("LGORT"));
        #lines.setValue("MOVE_STLOC", m.get("NLOGRT"));
        lines.setValue('BATCH', po.charg)
        lines.setValue('MOVE_TYPE', '101')
        lines.setValue('MVT_IND', 'B')
        lines.setValue('ENTRY_QNT', po.alloc_qty)
        lines.setValue('ENTRY_UOM', po.meins)
        lines.setValue('PO_NUMBER', po.ebeln)
        lines.setValue('PO_ITEM', po.ebelp)
        lines.setValue('VENDRBATCH', po.date_code)
        lines.setValue('PROD_DATE', po.mfg_date)
        lines.setValue('VENDOR', po.lifnr)
        lines.setValue('ITEM_TEXT', "#{po.lifdn}_#{po.invnr}")
      end
      com.sap.conn.jco.JCoContext.begin(dest)
      function.execute(dest)
      commit.execute(dest)
      com.sap.conn.jco.JCoContext.end(dest)

      posting_success = true
      returnMessage = function.getTableParameterList().getTable('RETURN')
      (1..returnMessage.getNumRows).each do |i|
        puts "#{i} Type:#{returnMessage.getString('TYPE')}, MSG:#{returnMessage.getString('MESSAGE')}"
        if returnMessage.getString('TYPE').eql?('E')
          posting_success = false
          rfc_msg = "ID: #{returnMessage.getString('ID')} NUMBER: #{returnMessage.getString('NUMBER')} MESSAGE: #{returnMessage.getString('MESSAGE')}"
          PoReceiptMsg.create(
              lifnr: dlv_note.lifnr, lifdn: dlv_note.lifdn, werks: dlv_note.werks, invnr: dlv_note.invnr,
              rfc_type: returnMessage.getString('TYPE'), rfc_msg: rfc_msg
          )
        end
        returnMessage.nextRow
      end
      sql = "
          select distinct b.uuid,b.po_receipt_id
            from po_receipt a
              join po_receipt_line b on b.po_receipt_id = a.uuid
            where a.status='20' and b.status='20' and a.lifnr = ? and a.lifdn = ?
              and a.werks=? and nvl(b.invnr,' ') = ?
        "
      ids = PoReceipt.find_by_sql([sql, dlv_note.lifnr, dlv_note.lifdn, dlv_note.werks, dlv_note.invnr])

      PoReceipt.transaction do
        if posting_success
          mblnr = function.getExportParameterList().getString('MATERIALDOCUMENT')
          mjahr = function.getExportParameterList().getString('MATDOCUMENTYEAR')
          ids.group_by(& :po_receipt_id).each do |po_receipt_id, po_receipt_line_ids|
            PoReceiptLine.where(uuid: po_receipt_line_ids)
                .update_all(status: '30', mblnr: mblnr, mjahr: mjahr, rfc_at: Time.now, rfc_type: 'S')
            if PoReceiptLine.where(status: '20', po_receipt_id: po_receipt_id).count == 0
              po_receipt = PoReceipt.find po_receipt_id
              po_receipt.status = '30'
              po_receipt.save
            end
          end
        else
          ids.group_by(& :po_receipt_id).each do |po_receipt_id, po_receipt_line_ids|
            PoReceiptLine.where(uuid: po_receipt_line_ids).update_all(rfc_type: 'E')
            po_receipt = PoReceipt.find po_receipt_id
            po_receipt.rfc_sts = 'E'
            po_receipt.save
          end
        end
      end
    end

  end

  def self.vtweg(werks)
    if werks.eql?('111A') or werks.eql?('112A')
      'PH'
    elsif werks.eql?('481A') or werks.eql?('482A')
      'DT'
    else
      'TX'
    end
  end
end