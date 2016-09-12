class AddNameToUsers < ActiveRecord::Migration
  def change
    add_column 'user_ldap', :name, :string
  end
end
