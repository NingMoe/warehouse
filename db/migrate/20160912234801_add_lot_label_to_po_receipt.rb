class AddLotLabelToPoReceipt < ActiveRecord::Migration
  def change
    add_column :po_receipt, :lot_label, :string, default: ' '
    add_index :po_receipt, [:lot_label, :vtweg]
  end
end
