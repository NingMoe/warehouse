class AddVtwegToUserLdap < ActiveRecord::Migration
  def change
    add_column 'user_ldap', :vtweg, :string
  end
end
