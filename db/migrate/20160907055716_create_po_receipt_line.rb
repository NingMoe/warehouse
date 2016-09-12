class CreatePoReceiptLine < ActiveRecord::Migration
  def change
    create_table :po_receipt_line, id: false do |t|
      t.string :uuid, null: false
      t.string :po_receipt_id, null: false
      t.string :status, null: false
      t.string :impnr
      t.string :impim
      t.string :invnr
      t.string :ebeln, null: false
      t.string :ebelp, null: false
      t.decimal :netpr, precision: 15, scale: 6, default: 0
      t.decimal :peinh, precision: 15, scale: 6, default: 0
      t.decimal :alloc_qty, precision: 15, scale: 6, default: 0
      t.date :rfc_at
      t.string :rfc_type
      t.text :rfc_msg
      t.string :budat
      t.string :mblnr
      t.string :mjahr
      t.string :zeile
      t.decimal :menge, precision: 15, scale: 6, default: 0
      t.string :meins
      t.string :charg
      t.string :creator
      t.string :updater
      t.timestamps null: false
    end
    add_index :po_receipt_line, :uuid, unique: true
    add_index :po_receipt_line, :po_receipt_id
    add_index :po_receipt_line, [:status, :ebeln, :ebelp]
  end
end
