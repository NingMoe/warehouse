class CreateSupplierDnLine < ActiveRecord::Migration
  def change
    create_table :supplier_dn_line, id: false do |t|
      t.string :uuid, null: false
      t.string :supplier_dn_id, null: false
      t.integer :seq, null: false, default: 0
      t.string :matnr, null: false
      t.string :ebeln
      t.string :ebelp
      t.string :charg
      t.string :meins
      t.decimal :menge, precision: 15, scale: 6, default: 0
      t.string :date_code, null: false, default: ' '
      t.string :mfg_date, null: false
      t.integer :total_box, null: false, default: 0
      t.decimal :qty_per_box, precision: 15, scale: 6, default: 0
      t.decimal :total_qty, precision: 15, scale: 6, default: 0
      t.string :creator
      t.string :updater

      t.timestamps null: false
    end
    add_index :supplier_dn_line, :uuid, unique: true
    add_index :supplier_dn_line, [:supplier_dn_id, :seq]
  end
end
