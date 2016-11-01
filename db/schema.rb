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

ActiveRecord::Schema.define(version: 20161031082937) do

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
  add_index "barcode", ["uuid"], name: "sys_c0011373", unique: true

  create_table "lot_ref", id: false, force: :cascade do |t|
    t.string "uuid",       null: false
    t.string "charg",      null: false
    t.string "entry_date", null: false
    t.string "matnr",      null: false
    t.string "lifnr",      null: false
    t.string "date_code",  null: false
  end

  add_index "lot_ref", ["charg"], name: "sys_c0011377", unique: true
  add_index "lot_ref", ["entry_date", "matnr", "lifnr", "date_code"], name: "ib80be9714022621f234094b100dee"
  add_index "lot_ref", ["uuid"], name: "sys_c0011378", unique: true

# Could not dump table "po_receipt" because of following Java::JavaLangInvoke::WrongMethodTypeException
#   cannot explicitly cast MethodHandle(RubyObjectVar3)Object to (IRubyObject,IRubyObject[],Block)IRubyObject

# Could not dump table "po_receipt_line" because of following Java::JavaLangInvoke::WrongMethodTypeException
#   cannot explicitly cast MethodHandle(RubyObjectVar3)Object to (IRubyObject,IRubyObject[],Block)IRubyObject

# Could not dump table "po_receipt_msg" because of following Java::JavaLangInvoke::WrongMethodTypeException
#   cannot explicitly cast MethodHandle(RubyObjectVar3)Object to (IRubyObject,IRubyObject[],Block)IRubyObject

# Could not dump table "printer" because of following Java::JavaLangInvoke::WrongMethodTypeException
#   cannot explicitly cast MethodHandle(RubyObjectVar3)Object to (IRubyObject,IRubyObject[],Block)IRubyObject

# Could not dump table "rfc_msg" because of following Java::JavaLangInvoke::WrongMethodTypeException
#   cannot explicitly cast MethodHandle(RubyObjectVar3)Object to (IRubyObject,IRubyObject[],Block)IRubyObject

# Could not dump table "saprfc_mb1b" because of following Java::JavaLangInvoke::WrongMethodTypeException
#   cannot explicitly cast MethodHandle(RubyObjectVar3)Object to (IRubyObject,IRubyObject[],Block)IRubyObject

# Could not dump table "saprfc_vl02" because of following Java::JavaLangInvoke::WrongMethodTypeException
#   cannot explicitly cast MethodHandle(RubyObjectVar3)Object to (IRubyObject,IRubyObject[],Block)IRubyObject

# Could not dump table "sto" because of following Java::JavaLangInvoke::WrongMethodTypeException
#   cannot explicitly cast MethodHandle(RubyObjectVar3)Object to (IRubyObject,IRubyObject[],Block)IRubyObject

# Could not dump table "stock_master" because of following Java::JavaLangInvoke::WrongMethodTypeException
#   cannot explicitly cast MethodHandle(RubyObjectVar3)Object to (IRubyObject,IRubyObject[],Block)IRubyObject

# Could not dump table "stock_tran" because of following Java::JavaLangInvoke::WrongMethodTypeException
#   cannot explicitly cast MethodHandle(RubyObjectVar3)Object to (IRubyObject,IRubyObject[],Block)IRubyObject

# Could not dump table "storage" because of following Java::JavaLangInvoke::WrongMethodTypeException
#   cannot explicitly cast MethodHandle(RubyObjectVar3)Object to (IRubyObject,IRubyObject[],Block)IRubyObject

# Could not dump table "supplier_dn" because of following Java::JavaLangInvoke::WrongMethodTypeException
#   cannot explicitly cast MethodHandle(RubyObjectVar3)Object to (IRubyObject,IRubyObject[],Block)IRubyObject

# Could not dump table "supplier_dn_line" because of following Java::JavaLangInvoke::WrongMethodTypeException
#   cannot explicitly cast MethodHandle(RubyObjectVar3)Object to (IRubyObject,IRubyObject[],Block)IRubyObject

# Could not dump table "user" because of following Java::JavaLangInvoke::WrongMethodTypeException
#   cannot explicitly cast MethodHandle(RubyObjectVar3)Object to (IRubyObject,IRubyObject[],Block)IRubyObject

# Could not dump table "user_ldap" because of following Java::JavaLangInvoke::WrongMethodTypeException
#   cannot explicitly cast MethodHandle(RubyObjectVar3)Object to (IRubyObject,IRubyObject[],Block)IRubyObject

# Could not dump table "ziebi002" because of following Java::JavaLangInvoke::WrongMethodTypeException
#   cannot explicitly cast MethodHandle(RubyObjectVar3)Object to (IRubyObject,IRubyObject[],Block)IRubyObject

  add_synonym "users", "istock.user", force: true

end
