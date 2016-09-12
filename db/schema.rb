# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20160909060849) do

  create_table "barcode", id: false, force: :cascade do |t|
    t.string   "uuid",                           null: false
    t.string   "name"
    t.string   "stock_master_id"
    t.string   "parent_id"
    t.string   "child"
    t.string   "old_id"
    t.string   "lgort"
    t.string   "status"
    t.integer  "menge",           precision: 38
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.string   "storage"
    t.integer  "seq",             precision: 38
  end

  add_index "barcode", ["name"], name: "index_barcode_on_name"
  add_index "barcode", ["seq"], name: "index_barcode_on_seq"
  add_index "barcode", ["storage"], name: "index_barcode_on_storage"
  add_index "barcode", ["uuid"], name: "index_barcode_on_uuid", unique: true

  create_table "lot_ref", id: false, force: :cascade do |t|
    t.string "uuid",       null: false
    t.string "charg",      null: false
    t.string "entry_date", null: false
    t.string "matnr",      null: false
    t.string "lifnr",      null: false
    t.string "date_code",  null: false
  end

  add_index "lot_ref", ["charg"], name: "index_lot_ref_on_charg", unique: true
  add_index "lot_ref", ["entry_date", "matnr", "lifnr", "date_code"], name: "ib80be9714022621f234094b100dee"
  add_index "lot_ref", ["uuid"], name: "index_lot_ref_on_uuid", unique: true

  create_table "po_receipt", id: false, force: :cascade do |t|
    t.string   "uuid",                                              null: false
    t.string   "barcode",                                           null: false
    t.string   "vtweg",                                             null: false
    t.string   "lifnr",                                             null: false
    t.string   "lifdn",                                             null: false
    t.string   "matnr",                                             null: false
    t.string   "werks",                                             null: false
    t.decimal  "pkg_no",     precision: 15, scale: 6, default: 0.0
    t.string   "date_code",                                         null: false
    t.string   "mfg_date",                                          null: false
    t.string   "entry_date",                                        null: false
    t.decimal  "menge",      precision: 15, scale: 6, default: 0.0
    t.decimal  "alloc_qty",  precision: 15, scale: 6, default: 0.0
    t.decimal  "balqty",     precision: 15, scale: 6, default: 0.0
    t.string   "status",                                            null: false
    t.string   "vtype",                                             null: false
    t.string   "impnr"
    t.string   "charg"
    t.string   "remote_ip"
    t.string   "creator"
    t.string   "updater"
    t.datetime "created_at",                                        null: false
    t.datetime "updated_at",                                        null: false
    t.string   "rfc_sts",                             default: " ", null: false
    t.string   "dpseq"
    t.string   "bukrs"
  end

  add_index "po_receipt", ["barcode"], name: "index_po_receipt_on_barcode", unique: true
  add_index "po_receipt", ["bukrs", "dpseq", "lifnr", "matnr", "werks"], name: "i_po_rec_buk_dps_lif_mat_wer"
  add_index "po_receipt", ["lifnr", "lifdn"], name: "i_po_receipt_lifnr_lifdn"
  add_index "po_receipt", ["uuid"], name: "index_po_receipt_on_uuid", unique: true
  add_index "po_receipt", ["vtype", "status"], name: "i_po_receipt_vtype_status"

  create_table "po_receipt_line", id: false, force: :cascade do |t|
    t.string   "uuid",                                                 null: false
    t.string   "po_receipt_id",                                        null: false
    t.string   "status",                                               null: false
    t.string   "impnr"
    t.string   "impim"
    t.string   "invnr",                                  default: " ", null: false
    t.string   "ebeln",                                                null: false
    t.string   "ebelp",                                                null: false
    t.decimal  "netpr",         precision: 15, scale: 6, default: 0.0
    t.decimal  "peinh",         precision: 15, scale: 6, default: 0.0
    t.decimal  "alloc_qty",     precision: 15, scale: 6, default: 0.0
    t.datetime "rfc_at"
    t.string   "rfc_type"
    t.text     "rfc_msg"
    t.string   "budat"
    t.string   "mblnr"
    t.string   "mjahr"
    t.string   "zeile"
    t.decimal  "menge",         precision: 15, scale: 6, default: 0.0
    t.string   "meins"
    t.string   "charg"
    t.string   "creator"
    t.string   "updater"
    t.datetime "created_at",                                           null: false
    t.datetime "updated_at",                                           null: false
  end

  add_index "po_receipt_line", ["po_receipt_id"], name: "i_po_rec_lin_po_rec_id"
  add_index "po_receipt_line", ["status", "ebeln", "ebelp"], name: "i_po_rec_lin_sta_ebe_ebe"
  add_index "po_receipt_line", ["uuid"], name: "index_po_receipt_line_on_uuid", unique: true

  create_table "po_receipt_msg", id: false, force: :cascade do |t|
    t.string   "uuid",                     null: false
    t.string   "lifnr",                    null: false
    t.string   "lifdn",                    null: false
    t.string   "werks",                    null: false
    t.string   "invnr",      default: " ", null: false
    t.string   "rfc_type"
    t.text     "rfc_msg"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "po_receipt_msg", ["lifnr", "lifdn", "werks", "invnr"], name: "i_po_rec_msg_lif_lif_wer_inv"
  add_index "po_receipt_msg", ["uuid"], name: "index_po_receipt_msg_on_uuid", unique: true

  create_table "printer", id: false, force: :cascade do |t|
    t.string   "uuid",       null: false
    t.string   "code"
    t.string   "name"
    t.string   "ip"
    t.string   "port"
    t.string   "creator_id"
    t.string   "updater_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "printer", ["code"], name: "index_printer_on_code"
  add_index "printer", ["uuid"], name: "index_printer_on_uuid", unique: true

  create_table "saprfc_mb1b", id: false, force: :cascade do |t|
    t.string   "uuid",                                null: false
    t.string   "parent_id"
    t.string   "matnr"
    t.string   "werks"
    t.string   "lgort"
    t.string   "old_lgort"
    t.string   "charg"
    t.string   "bwart"
    t.decimal  "menge",      precision: 15, scale: 3
    t.string   "msg_type"
    t.string   "msg_id"
    t.string   "msg_number"
    t.string   "msg_text"
    t.string   "rfc_date"
    t.string   "status"
    t.string   "mjahr"
    t.string   "mblnr"
    t.string   "zeile"
    t.string   "creator"
    t.string   "updater"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  add_index "saprfc_mb1b", ["parent_id"], name: "index_saprfc_mb1b_on_parent_id"
  add_index "saprfc_mb1b", ["uuid"], name: "index_saprfc_mb1b_on_uuid", unique: true

  create_table "saprfc_vl02", id: false, force: :cascade do |t|
    t.string   "vbeln",      limit: 90,                           null: false
    t.string   "posnr",      limit: 54,                           null: false
    t.string   "matnr",      limit: 162,                          null: false
    t.string   "charg",      limit: 90,                           null: false
    t.decimal  "menge",                  precision: 13, scale: 3, null: false
    t.string   "meins",      limit: 27,                           null: false
    t.string   "werks",      limit: 36,                           null: false
    t.string   "lgort",      limit: 36,                           null: false
    t.string   "msg_type"
    t.string   "msg_id"
    t.string   "msg_number"
    t.string   "msg_text"
    t.string   "rfc_date"
    t.string   "status"
    t.string   "mjahr"
    t.string   "mblnr"
    t.string   "zeile"
    t.string   "creator"
    t.string   "updater"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "barcode_id"
    t.string   "uuid"
  end

  create_table "stock_master", id: false, force: :cascade do |t|
    t.string   "uuid",                      null: false
    t.string   "matnr"
    t.string   "maktx"
    t.string   "matkl"
    t.string   "charg"
    t.integer  "menge",      precision: 38
    t.integer  "box_cnt",    precision: 38
    t.integer  "pallet_cnt", precision: 38
    t.string   "werks"
    t.string   "meins"
    t.string   "mjahr"
    t.string   "mblnr"
    t.string   "zeile"
    t.string   "aufnr"
    t.string   "prdln"
    t.string   "ebeln"
    t.string   "ebelp"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.string   "datecode"
    t.string   "budat"
  end

  add_index "stock_master", ["aufnr"], name: "index_stock_master_on_aufnr"
  add_index "stock_master", ["matnr"], name: "index_stock_master_on_matnr"
  add_index "stock_master", ["mjahr", "mblnr", "zeile"], name: "i_sto_mas_mja_mbl_zei"
  add_index "stock_master", ["uuid"], name: "index_stock_master_on_uuid", unique: true

  create_table "stock_tran", id: false, force: :cascade do |t|
    t.string   "uuid",                       null: false
    t.string   "master_id"
    t.string   "barcode_id"
    t.string   "lgort_old"
    t.string   "lgort"
    t.string   "status"
    t.integer  "menge",       precision: 38
    t.string   "vbeln"
    t.string   "posnr"
    t.string   "meins"
    t.string   "mjahr"
    t.string   "mblnr"
    t.string   "zeile"
    t.string   "aufnr"
    t.string   "prdln"
    t.string   "ebeln"
    t.string   "ebelp"
    t.string   "mtype"
    t.string   "created_by"
    t.string   "created_ip"
    t.string   "created_mac"
    t.string   "updated_by"
    t.string   "updated_ip"
    t.string   "updated_mac"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.text     "reason"
  end

  add_index "stock_tran", ["barcode_id"], name: "index_stock_tran_on_barcode_id"
  add_index "stock_tran", ["master_id"], name: "index_stock_tran_on_master_id"
  add_index "stock_tran", ["uuid"], name: "index_stock_tran_on_uuid", unique: true

  create_table "storage", id: false, force: :cascade do |t|
    t.string   "uuid",       null: false
    t.string   "code"
    t.string   "name"
    t.string   "werks"
    t.string   "creator_id"
    t.string   "updater_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "storage", ["code"], name: "index_storage_on_code"
  add_index "storage", ["uuid"], name: "index_storage_on_uuid", unique: true

  create_table "user", id: false, force: :cascade do |t|
    t.string   "uuid",                                               null: false
    t.string   "email",                                 default: "", null: false
    t.string   "encrypted_password",                    default: ""
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          precision: 38, default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "username"
    t.string   "role"
    t.integer  "supplier_id",            precision: 38
    t.string   "territory"
    t.string   "printer_id"
  end

  add_index "user", ["email"], name: "index_user_on_email", unique: true
  add_index "user", ["reset_password_token"], name: "i_user_reset_password_token", unique: true
  add_index "user", ["username"], name: "index_user_on_username", unique: true
  add_index "user", ["uuid"], name: "index_user_on_uuid", unique: true

  create_table "user_ldap", id: false, force: :cascade do |t|
    t.string   "email",                                 default: "", null: false
    t.string   "encrypted_password",                    default: ""
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          precision: 38, default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                                         null: false
    t.datetime "updated_at",                                         null: false
    t.string   "name"
    t.string   "vtweg"
  end

  add_index "user_ldap", ["email"], name: "index_user_ldap_on_email", unique: true
  add_index "user_ldap", ["reset_password_token"], name: "i_use_lda_res_pas_tok", unique: true

  create_table "ziebi002", id: false, force: :cascade do |t|
    t.string   "uuid",                                              null: false
    t.string   "bukrs",                                             null: false
    t.string   "dpseq",                                             null: false
    t.string   "impnr",                                             null: false
    t.string   "impim",                                             null: false
    t.string   "invnr",                                             null: false
    t.string   "ebeln",                                             null: false
    t.string   "ebelp",                                             null: false
    t.string   "matnr",                                             null: false
    t.string   "lifnr",                                             null: false
    t.string   "meins",                                             null: false
    t.decimal  "menge",      precision: 15, scale: 6, default: 0.0
    t.decimal  "alloc_qty",  precision: 15, scale: 6, default: 0.0
    t.decimal  "balqty",     precision: 15, scale: 6, default: 0.0
    t.string   "status",                                            null: false
    t.string   "werks",                                             null: false
    t.datetime "created_at",                                        null: false
    t.datetime "updated_at",                                        null: false
    t.integer  "netpr",      precision: 38
    t.integer  "peinh",      precision: 38
  end

  add_index "ziebi002", ["bukrs", "dpseq", "lifnr", "matnr"], name: "i_zie_buk_dps_lif_mat"
  add_index "ziebi002", ["impnr", "impim"], name: "i_ziebi002_impnr_impim", unique: true
  add_index "ziebi002", ["uuid"], name: "index_ziebi002_on_uuid", unique: true

  add_synonym "users", "istock.user", force: true

end
