class AddPoReceiptIdToSto < ActiveRecord::Migration
  def change
    add_column :sto, :po_receipt_id, :string
    add_index :sto, :po_receipt_id
  end
end
