class AddDpseqToSupplierDn < ActiveRecord::Migration
  def change
    add_column :supplier_dn, :dpseq, :string
    add_column :po_receipt, :vbeln, :string
  end
end
