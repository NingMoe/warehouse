class CreateZiebi002 < ActiveRecord::Migration
  def change
    create_table :ziebi002, id: false do |t|
      t.string :uuid, null: false
      t.string :bukrs, null: false
      t.string :dpseq, null: false
      t.string :impnr, null: false
      t.string :impim, null: false
      t.string :invnr, null: false
      t.string :ebeln, null: false
      t.string :ebelp, null: false
      t.string :matnr, null: false
      t.string :lifnr, null: false
      t.string :meins, null: false
      t.decimal :menge, precision: 15, scale: 6, default: 0
      t.decimal :alloc_qty, precision: 15, scale: 6, default: 0
      t.decimal :balqty, precision: 15, scale: 6, default: 0
      t.string :status, null: false
      t.string :werks, null: false

      t.timestamps null: false
    end
    add_index :ziebi002, :uuid, unique: true
    add_index :ziebi002, [:bukrs, :dpseq, :lifnr, :matnr]
    add_index :ziebi002, [:impnr, :impim], unique: true
  end
end
