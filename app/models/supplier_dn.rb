class SupplierDn < ActiveRecord::Base
  self.primary_key = :uuid

  before_create :z_before_create, if: vtype.eql?('STO')

  def z_before_create
    sql = "
      with
        tlips as (
          select distinct a.vbeln,a.matnr,c.werks,a.vgbel,a.vgpos,b.lifnr
            from sapsr3.lips a
              left join sapsr3.ekko b on b.mandt='168' and b.ebeln=a.vgbel
              left join sapsr3.ekpo c on c.mandt='168' and c.ebeln=a.vgbel and c.ebelp=substr(a.vgpos,2,5)
            where a.mandt='168' and a.vbeln=?)
        select a.vbeln,a.matnr,a.werks,a.lifnr,
               b.ebeln,b.ebelp,b.charg,sum(decode(b.shkzg,'S',b.menge * -1, b.menge)) menge
          from tlips a
            join sapsr3.ekbe b on b.mandt='168' and b.ebeln=a.vgbel and b.ebelp=substr(a.vgpos,2,5) and b.vgabe in ('1','6')
          group by a.vbeln,a.matnr,a.werks,a.lifnr,b.ebeln,b.ebelp,b.charg
          having sum(decode(b.shkzg,'S',b.menge * -1, b.menge)) > 0
    "
    rows = Sapdb.find_by_sql([sql, vbeln])
    if rows.blank?
      errors.add(:vbeln, I18n.t('sto_dn_received_error'))
    else
      row = rows.first
      self.werks = row.werks
      self.lifnr = row.lifnr
    end
  end

end
