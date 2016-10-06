class AddLotLabelPrinterToUserLdap < ActiveRecord::Migration
  def change
    add_column :user_ldap, :lot_label_printer, :string
  end
end
