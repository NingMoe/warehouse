class CreateMoIssue < ActiveRecord::Migration
  def change
    create_table :mo_issue, id: false do |t|
      t.string :uuid, null: false
      t.string :budat
      t.string :mblnr
      t.string :mjahr
      t.string :zeile
      t.string :aufnr
      t.string :matnr, null: false
      t.string :charg, null: false
      t.decimal :menge, precision: 15, scale: 6, default: 0
      t.string :lgort
      t.string :posnr
      t.string :rsnum
      t.string :rspos
      t.string :work_center
      t.string :prod_line
      t.date :created_time, null: false
      t.string :printed, null:false, default: ' '
      t.string :mes_teop_id
    end
    add_index :mo_issue, :uuid, unique: true
  end
end
