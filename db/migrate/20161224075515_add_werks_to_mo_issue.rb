class AddWerksToMoIssue < ActiveRecord::Migration
  def change
    add_column :mo_issue, :werks, :string
    add_index :mo_issue, [:printed, :werks, :budat]
  end
end
