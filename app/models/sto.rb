class Sto < ActiveRecord::Base
  self.primary_key = :uuid

  def self.create_by_impnr(impnr,invnr)
    sql = "
      select a.impnr,a.impim,a.invnr,a.ebeln,a.ebelp,a.matnr,a.menge,a.meins,
             b.reswk,c.werks,b.lifnr
        from sapsr3.ziebi002 a
          join sapsr3.ekko b on b.mandt=a.mandt and b.ebeln=a.ebeln
          join sapsr3.ekpo c on c.mandt=a.mandt and c.ebeln=a.ebeln and c.ebelp=a.ebelp
        where a.mandt='168' and a.impnr='#{impnr}' and a.invnr like ('%#{invnr}%')
    "
    Sapdb.find_by_sql(sql)
  end

  def self.open_sto_find_by_po(ebeln,ebelp,reswk)
    # sql = "
    #   with
    #     tmpa as
    #       (
    #         select a.bsart,b.ebeln,b.ebelp,a.bedat,b.matnr,b.txz01,b.matkl,(b.netpr/b.peinh) netpr, b.menge,b.meins,c.eindt,
    #                sum(c.menge-c.wemng) balqty, sum(c.glmng) dlvqty, sum(c.wemng) rcvqty, sum(c.glmng-c.wemng) otwqty,
    #                b.werks,a.reswk,a.lifnr
    #           from sapsr3.ekpo b
    #             join sapsr3.ekko a on a.mandt=b.mandt and a.ebeln=b.ebeln and a.bsart = 'Z006'
    #             join sapsr3.eket c on c.mandt=b.mandt and c.ebeln=b.ebeln and c.ebelp=b.ebelp and c.menge <> 0
    #           where b.mandt='168' and b.ebeln='#{ebeln}' and b.ebelp like '%#{ebelp}%' and b.elikz=' ' and b.loekz=' '
    #           group by a.bsart,b.ebeln,b.ebelp,a.bedat,b.matnr,b.txz01,b.matkl,(b.netpr/b.peinh), b.menge,b.meins, c.eindt,
    #                    a.reswk,b.werks,a.lifnr
    #           having sum(c.menge-c.wemng) <> 0)
    #     select a.bsart,a.ebeln,a.ebelp,a.bedat,a.matnr,a.txz01,a.matkl,a.netpr,a.menge,a.meins,
    #            a.eindt,a.balqty,a.dlvqty,a.rcvqty,a.otwqty,a.werks,a.reswk,a.lifnr,sum(b.labst)on_hand
    #       from tmpa a
    #         left join sapsr3.mard b on b.mandt='168' and b.matnr=a.matnr and b.werks=a.werks
    #       group by a.bsart,a.ebeln,a.ebelp,a.bedat,a.matnr,a.txz01,a.matkl,a.netpr,a.menge,a.meins,
    #                a.eindt,a.balqty,a.dlvqty,a.rcvqty,a.otwqty,a.werks,a.reswk,a.lifnr
    # "
    sql = "
        select a.bsart,b.ebeln,b.ebelp,a.bedat,b.matnr,b.txz01,b.matkl,(b.netpr/b.peinh) netpr, b.menge,b.meins,c.eindt,
               sum(c.menge-c.wemng) balqty, sum(c.glmng) dlvqty, sum(c.wemng) rcvqty, sum(c.glmng-c.wemng) otwqty,
               sum(c.mng02) cmtqty,
               b.werks,a.reswk,a.lifnr
          from sapsr3.ekpo b
            join sapsr3.ekko a on a.mandt=b.mandt and a.ebeln=b.ebeln and a.bsart = 'Z006' and a.reswk like '%#{reswk}%'
            join sapsr3.eket c on c.mandt=b.mandt and c.ebeln=b.ebeln and c.ebelp=b.ebelp and (c.menge <> 0 or (c.glmng=0 and c.wemng=0))
          where b.mandt='168' and b.ebeln='#{ebeln}' and b.ebelp like '%#{ebelp}%' and b.elikz=' ' and b.loekz=' '
          group by a.bsart,b.ebeln,b.ebelp,a.bedat,b.matnr,b.txz01,b.matkl,(b.netpr/b.peinh), b.menge,b.meins, c.eindt,
                   a.reswk,b.werks,a.lifnr
          having sum(c.menge-c.wemng) <> 0
    "
    Sapdb.find_by_sql(sql)
  end

  def self.open_sto_find_by_material(matnr,reswk)
    sql = "
        select a.bsart,b.ebeln,b.ebelp,a.bedat,b.matnr,b.txz01,b.matkl,(b.netpr/b.peinh) netpr, b.menge,b.meins,c.eindt,
               sum(c.menge-c.wemng) balqty, sum(c.glmng) dlvqty, sum(c.wemng) rcvqty, sum(c.glmng-c.wemng) otwqty,
               sum(c.mng02) cmtqty,
               b.werks,a.reswk,a.lifnr
          from sapsr3.ekpo b
            join sapsr3.ekko a on a.mandt=b.mandt and a.ebeln=b.ebeln and a.bsart = 'Z006' and a.reswk like '%#{reswk}%'
            join sapsr3.eket c on c.mandt=b.mandt and c.ebeln=b.ebeln and c.ebelp=b.ebelp and (c.menge <> 0 or (c.glmng=0 and c.wemng=0))
          where b.mandt='168' and b.matnr='#{matnr}' and b.elikz=' ' and b.loekz=' '
          group by a.bsart,b.ebeln,b.ebelp,a.bedat,b.matnr,b.txz01,b.matkl,(b.netpr/b.peinh), b.menge,b.meins, c.eindt,
                   a.reswk,b.werks,a.lifnr
          having sum(c.menge-c.wemng) <> 0
    "
    Sapdb.find_by_sql(sql)
  end

  #po_ids [ebeln.ebelp,...]
  def self.get_sap_po(po_ids)
    po_line_array = []
    po_ids.each do |po_id|
      buf = po_id.split('.')
      po_line_array.append "('#{buf[0]}','#{buf[1]}')"
    end

    sql = "
        select a.bsart,b.ebeln,b.ebelp,a.bedat,b.matnr,b.txz01,b.matkl,(b.netpr/b.peinh) netpr, b.menge,b.meins,
               b.werks,a.reswk,a.lifnr
          from sapsr3.ekpo b
            join sapsr3.ekko a on a.mandt=b.mandt and a.ebeln=b.ebeln
          where b.mandt='168' and b.elikz=' ' and b.loekz=' ' and (b.ebeln,b.ebelp) in (#{po_line_array.join(',')})
    "
    Sapdb.find_by_sql(sql)
  end


end
