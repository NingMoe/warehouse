class CreatePoReceiptMsg < ActiveRecord::Migration
  def change
    create_table :po_receipt_msg, id: false do |t|
      t.string :uuid, null: false
      t.string :lifnr, null: false
      t.string :lifdn, null: false
      t.string :werks, null: false
      t.string :invnr, null: false, default: ' '
      t.string :rfc_type
      t.text :rfc_msg

      t.timestamps null: false
    end
    add_index :po_receipt_msg, :uuid, unique: true
    add_index :po_receipt_msg, [:lifnr, :lifdn, :werks, :invnr]
  end
end
