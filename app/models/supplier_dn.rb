class SupplierDn < ActiveRecord::Base
  self.primary_key = :uuid
  has_many :supplier_dn_lines, class_name: 'SupplierDnLine', foreign_key: 'supplier_dn_id', dependent: :destroy

  def create_sto
    sql = "
      with
        tlips as (
          select distinct a.vbeln,a.matnr,c.werks,a.vgbel,a.vgpos,b.lifnr,c.meins
            from sapsr3.lips a
              left join sapsr3.ekko b on b.mandt='168' and b.ebeln=a.vgbel
              left join sapsr3.ekpo c on c.mandt='168' and c.ebeln=a.vgbel and c.ebelp=substr(a.vgpos,2,5)
            where a.mandt='168' and a.vbeln=?)
        select a.vbeln,a.matnr,a.werks,a.lifnr,a.meins,
               b.ebeln,b.ebelp,b.charg,c.budat,sum(decode(b.shkzg,'S',b.menge * -1, b.menge)) menge
          from tlips a
            join sapsr3.ekbe b on b.mandt='168' and b.ebeln=a.vgbel and b.ebelp=substr(a.vgpos,2,5) and b.vgabe in ('1','6')
            left join tmplum.mch1x c on c.matnr=a.matnr and c.charg=b.charg
          group by a.vbeln,a.matnr,a.werks,a.lifnr,b.ebeln,b.ebelp,b.charg,c.budat,a.meins
          having sum(decode(b.shkzg,'S',b.menge * -1, b.menge)) > 0
    "
    rows = Sapdb.find_by_sql([sql, vbeln])
    if rows.present?
      xrow = rows.first
      SupplierDn.transaction do
        if impnr.present?
          buf = impnr.split('|')
          if buf.size > 1
            self.dpseq = buf[0]
            self.impnr = buf[1]
          end
        end
        self.werks = xrow.werks
        self.vtweg = PoReceipt.vtweg(werks)
        self.lifnr = xrow.lifnr
        self.status = '10'
        self.uuid = assign_uuid
        self.save
        seq = 0
        rows.each do |row|
          seq += 1000
          SupplierDnLine.create(
              supplier_dn_id: uuid, seq: seq, matnr: row.matnr, ebeln: row.ebeln, ebelp: row.ebelp,
              charg: row.charg, meins: row.meins, menge: row.menge, date_code: row.charg, mfg_date: row.budat,
              total_box: 1, qty_per_box: row.menge, total_qty: row.menge,
              creator: creator, updater: updater
          )
        end
      end
    end
  end

  def create_po_receipt
    SupplierDn.transaction do
      pkg_no = 0
      supplier_dn_lines.each do |line|
        total_box.times do
          pkg_no = pkg_no + 1
          PoReceipt.create(
             barcode: "@#{line.matnr}@#{werks}@#{lifnr}@#{lifdn}@#{line.date_code}@#{line.mfg_date}@#{line.qty_per_box}@#{pkg_no}@#{Time.now.strftime('%Y%m%d%H%M%S')}",
             vtweg: vtweg,
             lifnr: lifnr,
             lifdn: lifdn,
             matnr: line.matnr,
             werks: werks,
             pkg_no: pkg_no,
             date_code: line.date_code,
             mfg_date: line.mfg_date,
             entry_date: Time.now.strftime('%Y%m%d'),
             menge: line.qty_per_box,
             alloc_qty: 0,
             balqty: line.qty_per_box,
             status: '10',
             vtype: impnr.present? ? 'V1' : ' ',
             impnr: impnr,
             charg: charg,
             remote_ip: 'STO',
             creator: updater,
             updater: updater,
             dpseq: dpseq,
             bukrs: vtweg.eql?('TX') ? 'L300' : 'L400',
             vbeln: vbeln
          )
        end
      end
    end
  end

end
