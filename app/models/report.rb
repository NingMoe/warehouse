class Report

  def self.open_sto_list(lifnr,bukrs)
    sql = "
    select a.bsart,b.ebeln,b.ebelp,a.bedat,b.matnr,b.txz01,b.matkl,(b.netpr/b.peinh) netpr, b.menge,b.meins,c.eindt,
           sum(c.menge-c.wemng) balqty, sum(c.glmng) dlvqty, sum(c.wemng) rcvqty, sum(c.glmng-c.wemng) otwqty
      from sapsr3.ekko a
        join sapsr3.ekpo b on b.mandt=a.mandt and b.ebeln=a.ebeln and b.elikz=' ' and b.loekz=' '
        join sapsr3.eket c on c.mandt=b.mandt and c.ebeln=b.ebeln and c.ebelp=b.ebelp and c.menge <> 0
      where a.mandt='168' and a.lifnr=? and a.bukrs=?
      group by a.bsart,b.ebeln,b.ebelp,a.bedat,b.matnr,b.txz01,b.matkl,(b.netpr/b.peinh), b.menge,b.meins, c.eindt
      having sum(c.menge-c.wemng) <> 0
      order by a.bedat
    "
    Sapdb.find_by_sql([sql, lifnr, bukrs])
  end

end