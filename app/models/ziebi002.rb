class Ziebi002 < ActiveRecord::Base
  self.primary_key = :uuid

  def self.check_barcode(bukrs, dpseq, barcode)
    if (Ziebi002.where(bukrs: bukrs, dpseq: dpseq)
            .where(lifnr: barcode[:lifnr])
            .where(matnr: barcode[:matnr])
            .where(werks: barcode[:werks])
            .where("rownum = 1")).blank?
      return "此料號:#{barcode[:matnr]},#{barcode[:lifnr]},#{barcode[:werks]}沒有在IEB進口號里"
    else
      return ''
    end
  end

  def self.create_record_from_sap(impnrs)
    sql = "
      select a.impnr,a.impim,a.invnr,a.ebeln,a.ebelp,a.matnr,a.netpr,a.peinh,
             a.meins,a.menge,b.lifnr,c.werks,d.bukrs,d.dpseq
        from sapsr3.ziebi002 a
          join sapsr3.ekko b on b.mandt='168' and b.ebeln=a.ebeln
          join sapsr3.ekpo c on c.mandt='168' and c.ebeln=a.ebeln and c.ebelp=a.ebelp
          join sapsr3.ziebi001 d on d.mandt='168' and d.impnr=a.impnr
        where a.mandt='168' and impnr in (?)
    "
    rows = Sapdb.find_by_sql([sql, impnrs])
    rows.each do |row|
      Ziebi002.create(
          bukrs: row.bukrs, dpseq: row.dpseq, impnr: row.impnr, impim: row.impim,
          invnr: row.invnr, ebeln: row.ebeln, ebelp: row.ebelp, matnr: row.matnr,
          lifnr: row.lifnr, meins: row.meins, menge: row.menge, balqty: row.menge,
          netpr: row.netpr, peinh: row.peinh, alloc_qty: 0,
          status: '10', werks: row.werks
      )
    end
  end

  def self.import_order_list(vtweg)
    current_month = Date.today.strftime('%y%m')
    last_month = (Date.today - 1.month).strftime('%y%m')
    if vtweg.present?
      if vtweg.eql?('TX')
        impnr = "(impnr between 'ITX#{last_month}' and 'ITX#{current_month}Z')"
      else
        impnr = "(impnr between 'DIM#{last_month}' and 'DIM#{current_month}Z')"
      end
    else
      impnr = "((impnr between 'ITX#{last_month}' and 'ITX#{current_month}Z') or (impnr between 'DIM#{last_month}' and 'DIM#{current_month}Z'))"
    end
    sql = "
      select dpseq,impnr
        from sapsr3.ziebi001
        where mandt='168' and #{impnr}
          and loekz=' '
        order by dpseq desc,impnr
    "
    rows = Sapdb.find_by_sql(sql)
    array = []
    rows.group_by(& :dpseq).each do |dpseq, impnrs|
      impnr = []
      impnrs.each{|row| impnr << row.impnr}
      array << [impnr.join(','), "#{dpseq}|#{impnr.join(',')}"]
    end
    array
  end

end
