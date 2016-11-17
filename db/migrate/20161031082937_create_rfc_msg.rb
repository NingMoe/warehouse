class CreateRfcMsg < ActiveRecord::Migration
  def change
    create_table :rfc_msg, id:false do |t|
      t.string :uuid, null: false
      t.string :rfc_batch_id, null:false
      t.string :rfc_msg_type
      t.string :rfc_id
      t.string :rfc_number
      t.string :rfc_message
      t.string :rfc_log_no
      t.string :rfc_log_msg_no
      t.string :rfc_message_v1
      t.string :rfc_message_v2
      t.string :rfc_message_v3
      t.string :rfc_message_v4
      t.string :rfc_parameter
      t.string :rfc_row
      t.string :rfc_field
      t.string :rfc_system

      t.timestamps null: false
    end
    add_index :rfc_msg, :uuid, unique: true
    add_index :rfc_msg, :rfc_batch_id
  end
end
