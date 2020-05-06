# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_05_06_064846) do

  create_table "container_materials", force: :cascade do |t|
    t.string "container_type"
    t.integer "container_id"
    t.string "material_type"
    t.integer "material_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["container_type", "container_id"], name: "index_container_materials_on_container_type_and_container_id"
    t.index ["material_type", "material_id"], name: "index_container_materials_on_material_type_and_material_id"
  end

  create_table "ont_libraries", force: :cascade do |t|
    t.string "name"
    t.string "plate_barcode"
    t.integer "pool"
    t.string "well_range"
    t.integer "pool_size"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "ont_library_requests", force: :cascade do |t|
    t.integer "ont_library_id"
    t.integer "ont_request_id"
    t.integer "tag_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["ont_library_id"], name: "index_ont_library_requests_on_ont_library_id"
    t.index ["ont_request_id"], name: "index_ont_library_requests_on_ont_request_id"
    t.index ["tag_id"], name: "index_ont_library_requests_on_tag_id"
  end

  create_table "ont_requests", force: :cascade do |t|
    t.string "external_study_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "pacbio_libraries", force: :cascade do |t|
    t.float "volume"
    t.float "concentration"
    t.string "library_kit_barcode"
    t.integer "fragment_size"
    t.string "uuid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "state"
    t.datetime "deactivated_at"
  end

  create_table "pacbio_plates", force: :cascade do |t|
    t.integer "pacbio_run_id"
    t.string "uuid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["pacbio_run_id"], name: "index_pacbio_plates_on_pacbio_run_id"
  end

  create_table "pacbio_request_libraries", force: :cascade do |t|
    t.integer "pacbio_request_id"
    t.integer "pacbio_library_id"
    t.integer "tag_id"
    t.index ["pacbio_library_id"], name: "index_pacbio_request_libraries_on_pacbio_library_id"
    t.index ["pacbio_request_id", "pacbio_library_id"], name: "index_rl_request_library"
    t.index ["pacbio_request_id"], name: "index_pacbio_request_libraries_on_pacbio_request_id"
    t.index ["tag_id", "pacbio_library_id"], name: "index_rl_tag_library"
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
    t.string "source_barcode"
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
    t.integer "state", default: 0
    t.datetime "deactivated_at"
    t.index ["name"], name: "index_pacbio_runs_on_name", unique: true
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

  create_table "plates", force: :cascade do |t|
    t.string "barcode"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
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
    t.string "species"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_samples_on_name", unique: true
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
    t.index ["name"], name: "index_saphyr_enzymes_on_name", unique: true
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

  create_table "tag_sets", force: :cascade do |t|
    t.string "name"
    t.string "uuid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tag_taggables", force: :cascade do |t|
    t.string "taggable_type"
    t.integer "taggable_id"
    t.integer "tag_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["tag_id"], name: "index_tag_taggables_on_tag_id"
    t.index ["taggable_type", "taggable_id"], name: "index_tag_taggables_on_taggable_type_and_taggable_id"
  end

  create_table "tags", force: :cascade do |t|
    t.string "oligo"
    t.string "group_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "tag_set_id"
    t.index ["group_id", "tag_set_id"], name: "index_tags_on_group_id_and_tag_set_id", unique: true
    t.index ["oligo", "tag_set_id"], name: "index_tags_on_oligo_and_tag_set_id", unique: true
    t.index ["tag_set_id"], name: "index_tags_on_tag_set_id"
  end

  create_table "tubes", force: :cascade do |t|
    t.string "barcode"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "wells", force: :cascade do |t|
    t.string "position"
    t.integer "plate_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["plate_id"], name: "index_wells_on_plate_id"
  end

end
