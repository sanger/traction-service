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

ActiveRecord::Schema.define(version: 2019_01_30_113208) do

  create_table "enzymes", force: :cascade do |t|
    t.string "name"
  end

  create_table "libraries", force: :cascade do |t|
    t.string "state"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "sample_id"
    t.datetime "deactivated_at"
    t.integer "enzyme_id"
    t.index ["enzyme_id"], name: "index_libraries_on_enzyme_id"
    t.index ["sample_id"], name: "index_libraries_on_sample_id"
  end

  create_table "samples", force: :cascade do |t|
    t.string "name"
    t.datetime "deactivated_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "sequencescape_request_id"
    t.string "species"
  end

  create_table "tubes", force: :cascade do |t|
    t.string "barcode"
    t.string "material_type"
    t.integer "material_id"
    t.index ["material_type", "material_id"], name: "index_tubes_on_material_type_and_material_id"
  end

end
