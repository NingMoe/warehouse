class AddNetprPeinhToZiebi002 < ActiveRecord::Migration
  def change
    add_column :ziebi002, :netpr, :decimal
    add_column :ziebi002, :peinh, :decimal
  end
end
