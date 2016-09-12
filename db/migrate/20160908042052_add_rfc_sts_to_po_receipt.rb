class AddRfcStsToPoReceipt < ActiveRecord::Migration
  def change
    add_column :po_receipt, :rfc_sts, :string, default: ' '
  end
end
