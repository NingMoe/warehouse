class AddDpseqBukrsToPoReceipt < ActiveRecord::Migration
  def change
    add_column :po_receipt, :dpseq, :string
    add_column :po_receipt, :bukrs, :string
  end
end
