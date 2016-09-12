class AddIndexToPoReceipt < ActiveRecord::Migration
  def change
    add_index :po_receipt, [:bukrs, :dpseq, :lifnr, :matnr, :werks]
  end
end
