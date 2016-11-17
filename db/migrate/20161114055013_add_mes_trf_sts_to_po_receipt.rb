class AddMesTrfStsToPoReceipt < ActiveRecord::Migration
  def change
    add_column :po_receipt, :mes_trf_sts, :string, default: ' '
    add_index :po_receipt, :mes_trf_sts
  end
end
