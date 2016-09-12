class CreateLotRef < ActiveRecord::Migration
  def change
    create_table :lot_ref, id:false do |t|
      t.string :uuid, null: false
      t.string :charg, null: false
      t.string :entry_date, null: false
      t.string :matnr, null: false
      t.string :lifnr, null: false
      t.string :date_code, null: false
    end
    add_index :lot_ref, :uuid, unique: true
    add_index :lot_ref, :charg, unique: true
    add_index :lot_ref, [:entry_date, :matnr, :lifnr, :date_code]
  end
end
