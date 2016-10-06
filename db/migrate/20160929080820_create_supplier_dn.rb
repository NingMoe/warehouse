class CreateSupplierDn < ActiveRecord::Migration
  def change
    create_table :supplier_dn, id: false do |t|
      t.string :uuid, null: false
      t.string :vtweg, null: false
      t.string :werks, null: false
      t.string :lifnr, null: false
      t.string :lifdn, null: false
      t.string :vbeln, null: false, default: ' '
      t.string :status, null: false
      t.string :vtype, null: false, default: ' '
      t.string :impnr, null: false, default: ' '
      t.string :remote_ip
      t.string :creator
      t.string :updater

      t.timestamps null: false
    end
    add_index :supplier_dn, :uuid, unique: true
    add_index :supplier_dn, [:lifnr, :lifdn], unique: true
    add_index :supplier_dn, :vbeln
  end
end
