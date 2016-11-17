class CreateSto < ActiveRecord::Migration
  def change
    create_table :sto, id: false do |t|
      t.string :uuid, null: false
      t.string :vtweg, null: false
      t.string :ebeln, null: false
      t.string :ebelp, null: false
      t.string :matnr, null: false
      t.string :werks_from, null: false
      t.string :werks_to, null: false
      t.decimal :menge, precision: 15, scale: 6, default: 0
      t.string :meins, null: false
      t.string :lifnr, null: false
      t.string :lifdn
      t.string :vbeln
      t.string :posnr
      t.string :status, null: false
      t.string :vtype
      t.string :impnr
      t.string :impim
      t.string :remote_ip
      t.string :creator
      t.string :updater
      t.string :rfc_batch_id, null: false, default: ' '
      t.string :rfc_msg_type

      t.timestamps null: false
    end
    add_index :sto, :uuid, unique: true
    add_index :sto, [:status, :vtweg]
  end
end
