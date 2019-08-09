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

ActiveRecord::Schema.define(version: 2019_08_09_103819) do

  create_table "pacbio_libraries", force: :cascade do |t|
    t.float "volume"
    t.float "concentration"
    t.string "library_kit_barcode"
    t.integer "fragment_size"
    t.string "uuid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "pacbio_plates", force: :cascade do |t|
    t.integer "pacbio_run_id"
    t.string "uuid"
    t.string "barcode"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["pacbio_run_id"], name: "index_pacbio_plates_on_pacbio_run_id"
  end

  create_table "pacbio_request_libraries", force: :cascade do |t|
    t.integer "pacbio_request_id"
    t.integer "pacbio_library_id"
    t.integer "tag_id"
    t.index ["pacbio_library_id"], name: "index_pacbio_request_libraries_on_pacbio_library_id"
    t.index ["pacbio_request_id"], name: "index_pacbio_request_libraries_on_pacbio_request_id"
    t.index ["tag_id"], name: "index_pacbio_request_libraries_on_tag_id"
  end

  create_table "pacbio_requests", force: :cascade do |t|
    t.string "library_type"
    t.integer "estimate_of_gb_required"
    t.integer "number_of_smrt_cells"
    t.string "cost_code"
    t.string "external_study_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "pacbio_runs", force: :cascade do |t|
    t.string "name"
    t.string "template_prep_kit_box_barcode"
    t.string "binding_kit_box_barcode"
    t.string "sequencing_kit_box_barcode"
    t.string "dna_control_complex_box_barcode"
    t.string "comments"
    t.string "uuid"
    t.integer "system_name", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "pacbio_well_libraries", force: :cascade do |t|
    t.integer "pacbio_well_id"
    t.integer "pacbio_library_id"
    t.index ["pacbio_library_id"], name: "index_pacbio_well_libraries_on_pacbio_library_id"
    t.index ["pacbio_well_id"], name: "index_pacbio_well_libraries_on_pacbio_well_id"
  end

  create_table "pacbio_wells", force: :cascade do |t|
    t.integer "pacbio_plate_id"
    t.string "row"
    t.string "column"
    t.decimal "movie_time", precision: 3, scale: 1
    t.integer "insert_size"
    t.float "on_plate_loading_concentration"
    t.string "comment"
    t.string "uuid"
    t.integer "sequencing_mode"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["pacbio_plate_id"], name: "index_pacbio_wells_on_pacbio_plate_id"
  end

  create_table "requests", force: :cascade do |t|
    t.integer "sample_id"
    t.string "requestable_type"
    t.integer "requestable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["requestable_type", "requestable_id"], name: "index_requests_on_requestable_type_and_requestable_id"
    t.index ["sample_id"], name: "index_requests_on_sample_id"
  end

  create_table "samples", force: :cascade do |t|
    t.string "name"
    t.datetime "deactivated_at"
    t.string "external_id"
    t.string "external_study_id"
    t.string "species"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "saphyr_chips", force: :cascade do |t|
    t.string "barcode"
    t.string "serial_number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "saphyr_run_id"
    t.index ["saphyr_run_id"], name: "index_saphyr_chips_on_saphyr_run_id"
  end

  create_table "saphyr_enzymes", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "saphyr_flowcells", force: :cascade do |t|
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "saphyr_chip_id"
    t.integer "saphyr_library_id"
    t.index ["saphyr_chip_id"], name: "index_saphyr_flowcells_on_saphyr_chip_id"
    t.index ["saphyr_library_id"], name: "index_saphyr_flowcells_on_saphyr_library_id"
  end

  create_table "saphyr_libraries", force: :cascade do |t|
    t.string "state"
    t.datetime "deactivated_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "saphyr_enzyme_id"
    t.integer "saphyr_request_id"
    t.index ["saphyr_enzyme_id"], name: "index_saphyr_libraries_on_saphyr_enzyme_id"
    t.index ["saphyr_request_id"], name: "index_saphyr_libraries_on_saphyr_request_id"
  end

  create_table "saphyr_requests", force: :cascade do |t|
    t.string "external_study_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "saphyr_runs", force: :cascade do |t|
    t.integer "state", default: 0
    t.string "name"
    t.datetime "deactivated_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tags", force: :cascade do |t|
    t.string "oligo"
    t.integer "group_id"
    t.string "set_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tubes", force: :cascade do |t|
    t.string "barcode"
    t.string "material_type"
    t.integer "material_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["material_type", "material_id"], name: "index_tubes_on_material_type_and_material_id"
  end

end
