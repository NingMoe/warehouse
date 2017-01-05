class MesTErpPoItem < ActiveRecord::Base
  self.table_name = :t_erp_po_item
  establish_connection :leimes

  def self.transfer_to_mes(po_receipt_id)
    sql = "
        select a.uuid,b.matkl,c.use_flag
          from po_receipt a
            join ipqcweb.sap_mara b on b.matnr=a.matnr
            join t_data_dictionary@leimes c on c.data_model_code = 'ITEM_GROUP' and c.data_value=b.matkl
          where a.mes_trf_sts =' ' and a.uuid = ?
    "
    po_receipts = PoReceipt.find_by_sql([sql, po_receipt_id])
    po_receipts.each do |row|
      po_receipt = PoReceipt.find(row.uuid)
      MesTErpPoItem.transaction do
        if row.use_flag.to_i == 1
          po_receipt_line = po_receipt.po_receipt_lines.first
          MesTErpPoItem.create(
              po_number: po_receipt_line.ebeln,
              item_line: po_receipt_line.ebelp,
              item_code: po_receipt.matnr,
              item_num: 0,
              item_lot: po_receipt.charg,
              item_sn: po_receipt.barcode.upcase,
              item_sn_qty: po_receipt.menge,
              receive_type: '1',
              supplier_code: po_receipt.lifnr,
              supplier_lot: po_receipt.date_code,
              supplier_date: po_receipt.mfg_date,
              plant: po_receipt.werks,
              supplier_dn: po_receipt.lifdn
          )
          po_receipt.mes_trf_sts = 'X'
        else
          po_receipt.mes_trf_sts = 'L'
        end
        po_receipt.save
      end
    end
  end

  def self.insert_record
    while true do
      #po_receipts = PoReceipt.where(mes_trf_sts: ' ', status: '30').limit(1000)
      sql = "
        select a.uuid,b.matkl,c.use_flag
          from po_receipt a
            join ipqcweb.sap_mara b on b.matnr=a.matnr
            join t_data_dictionary@leimes c on c.data_model_code = 'ITEM_GROUP' and c.data_value=b.matkl
          where a.mes_trf_sts =' ' and a.status = '30' and rownum < 1000
      "
      po_receipts = PoReceipt.find_by_sql(sql)
      break if po_receipts.blank?
      po_receipts.each do |row|
        po_receipt = PoReceipt.find(row.uuid)
        MesTErpPoItem.transaction do
          if row.use_flag.to_i == 1
            po_receipt_line = po_receipt.po_receipt_lines.first
            MesTErpPoItem.create(
                po_number: po_receipt_line.ebeln,
                item_line: po_receipt_line.ebelp,
                item_code: po_receipt.matnr,
                item_num: 0,
                item_lot: po_receipt.charg,
                item_sn: po_receipt.barcode.upcase,
                item_sn_qty: po_receipt.menge,
                receive_type: '0',
                supplier_code: po_receipt.lifnr,
                supplier_lot: po_receipt.date_code,
                supplier_date: po_receipt.mfg_date,
                plant: po_receipt.werks,
                supplier_dn: po_receipt.lifdn
            )
            po_receipt.mes_trf_sts = 'X'
          else
            po_receipt.mes_trf_sts = 'L'
          end
          po_receipt.save
        end
      end
    end
  end


end