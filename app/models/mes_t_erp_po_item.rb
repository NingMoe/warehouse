class MesTErpPoItem < ActiveRecord::Base
  self.table_name = :t_erp_po_item
  establish_connection :leimes

  def self.insert_record
    while true do
      po_receipts = PoReceipt.where(mes_trf_sts: ' ', status: '30').limit(1000)
      break if po_receipts.blank?
      po_receipts.each do |po_receipt|
        po_receipt_line = po_receipt.po_receipt_lines.first
        MesTErpPoItem.transaction do
          MesTErpPoItem.create(
              po_number: po_receipt_line.ebeln,
              item_line: po_receipt_line.ebelp,
              item_code: po_receipt.matnr,
              item_num: 0,
              item_lot: po_receipt.charg,
              item_sn: po_receipt.barcode,
              item_sn_qty: po_receipt.menge,
              receive_type: '0',
              supplier_code: po_receipt.lifnr,
              supplier_lot: po_receipt.date_code,
              supplier_date: po_receipt.mfg_date,
              plant: po_receipt.werks,
              supplier_dn: po_receipt.lifdn
          )
          po_receipt.mes_trf_sts = 'X'
          po_receipt.save
        end
      end
    end
  end


end