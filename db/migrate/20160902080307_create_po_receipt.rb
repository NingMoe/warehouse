class CreatePoReceipt < ActiveRecord::Migration
  def change
    create_table :po_receipt, id:false do |t|
      t.string :uuid, null: false
      t.string :barcode, null: false
      t.string :vtweg, null: false
      t.string :lifnr, null: false
      t.string :lifdn, null: false
      t.string :matnr, null: false
      t.string :werks, null: false
      t.decimal :pkg_no, precision: 15, scale: 6, default: 0
      t.string :date_code, null: false
      t.string :mfg_date, null: false
      t.string :entry_date, null: false
      t.decimal :menge, precision: 15, scale: 6, default: 0
      t.decimal :alloc_qty, precision: 15, scale: 6, default: 0
      t.decimal :balqty, precision: 15, scale: 6, default: 0
      t.string :status, null: false
      t.string :vtype, null: false
      t.string :impnr
      t.string :charg
      t.string :remote_ip
      t.string :creator
      t.string :updater

      t.timestamps null: false
    end
    add_index :po_receipt, :uuid, unique: true
    add_index :po_receipt, :barcode, unique: true
    add_index :po_receipt, [:lifnr, :lifdn]
    add_index :po_receipt, [:vtype, :status]
  end
end
