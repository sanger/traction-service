# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_03_25_120000) do
  create_table "aliquots", charset: "utf8mb3", force: :cascade do |t|
    t.integer "aliquot_type", default: 0, null: false
    t.float "concentration"
    t.datetime "created_at", null: false
    t.integer "insert_size"
    t.bigint "source_id"
    t.string "source_type"
    t.integer "state", default: 0, null: false
    t.bigint "tag_id"
    t.string "template_prep_kit_box_barcode"
    t.datetime "updated_at", null: false
    t.bigint "used_by_id"
    t.string "used_by_type"
    t.string "uuid"
    t.float "volume"
    t.index ["source_type", "source_id"], name: "index_aliquots_on_source"
    t.index ["tag_id"], name: "index_aliquots_on_tag_id"
    t.index ["used_by_type", "used_by_id"], name: "index_aliquots_on_used_by"
  end

  create_table "api_applications", charset: "utf8mb3", force: :cascade do |t|
    t.string "contact_email"
    t.string "contact_name", null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name", null: false
    t.datetime "updated_at", null: false
  end

  create_table "api_keys", charset: "utf8mb3", force: :cascade do |t|
    t.bigint "api_application_id", null: false
    t.datetime "created_at", null: false
    t.datetime "expires_at"
    t.string "key_digest", null: false
    t.datetime "last_used_at"
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["api_application_id", "status"], name: "index_api_keys_on_api_application_id_and_status"
    t.index ["api_application_id"], name: "index_api_keys_on_api_application_id"
    t.index ["key_digest"], name: "index_api_keys_on_key_digest", unique: true
  end

  create_table "annotation_types", charset: "utf8mb3", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_annotation_types_on_name", unique: true
  end

  create_table "annotations", charset: "utf8mb3", force: :cascade do |t|
    t.bigint "annotatable_id", null: false
    t.string "annotatable_type", null: false
    t.bigint "annotation_type_id", null: false
    t.string "comment", limit: 500, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "user", limit: 10, null: false
    t.index ["annotatable_type", "annotatable_id"], name: "index_annotations_on_annotatable"
    t.index ["annotation_type_id"], name: "index_annotations_on_annotation_type_id"
  end

  create_table "container_materials", charset: "utf8mb3", force: :cascade do |t|
    t.bigint "container_id", null: false
    t.string "container_type", null: false
    t.datetime "created_at", null: false
    t.bigint "material_id"
    t.string "material_type"
    t.datetime "updated_at", null: false
    t.index ["container_type", "container_id"], name: "index_container_materials_on_container_type_and_container_id"
    t.index ["material_type", "material_id"], name: "index_container_materials_on_material_type_and_material_id"
  end

  create_table "data_types", charset: "utf8mb3", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.integer "pipeline", null: false
    t.datetime "updated_at", null: false
    t.index ["pipeline", "name"], name: "index_data_types_on_pipeline_and_name", unique: true
    t.index ["pipeline"], name: "index_data_types_on_pipeline"
  end

  create_table "flipper_features", charset: "utf8mb3", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "key", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_flipper_features_on_key", unique: true
  end

  create_table "flipper_gates", charset: "utf8mb3", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "feature_key", null: false
    t.string "key", null: false
    t.datetime "updated_at", null: false
    t.string "value"
    t.index ["feature_key", "key", "value"], name: "index_flipper_gates_on_feature_key_and_key_and_value", unique: true
  end

  create_table "heron_ont_requests", charset: "utf8mb3", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "external_id"
    t.string "name"
    t.bigint "ont_library_id"
    t.datetime "updated_at", null: false
    t.string "uuid"
    t.index ["ont_library_id"], name: "index_heron_ont_requests_on_ont_library_id"
  end

  create_table "library_types", charset: "utf8mb3", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.string "external_identifier"
    t.string "name", null: false
    t.integer "pipeline", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_library_types_on_name", unique: true
    t.index ["pipeline"], name: "index_library_types_on_pipeline"
  end

  create_table "multi_pool_positions", charset: "utf8mb3", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "multi_pool_id"
    t.bigint "pool_id"
    t.string "pool_type"
    t.integer "position", null: false
    t.datetime "updated_at", null: false
    t.index ["multi_pool_id"], name: "index_multi_pool_positions_on_multi_pool_id"
    t.index ["pool_type", "pool_id"], name: "index_multi_pool_positions_on_pool", unique: true
  end

  create_table "multi_pools", charset: "utf8mb3", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "pipeline", null: false
    t.integer "pool_method", null: false
    t.datetime "updated_at", null: false
  end

  create_table "ont_flowcells", charset: "utf8mb3", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "flowcell_id"
    t.bigint "ont_pool_id"
    t.bigint "ont_run_id"
    t.integer "position"
    t.datetime "updated_at", null: false
    t.string "uuid"
    t.index ["ont_pool_id"], name: "index_ont_flowcells_on_ont_pool_id"
    t.index ["ont_run_id", "flowcell_id"], name: "index_ont_flowcells_on_ont_run_id_and_flowcell_id", unique: true
    t.index ["ont_run_id", "position"], name: "index_ont_flowcells_on_ont_run_id_and_position", unique: true
    t.index ["ont_run_id"], name: "index_ont_flowcells_on_ont_run_id"
  end

  create_table "ont_instruments", charset: "utf8mb3", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "instrument_type", null: false
    t.integer "max_number_of_flowcells", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.string "uuid"
    t.index ["name"], name: "index_ont_instruments_on_name", unique: true
  end

  create_table "ont_libraries", charset: "utf8mb3", force: :cascade do |t|
    t.float "concentration"
    t.datetime "created_at", null: false
    t.datetime "deactivated_at", precision: nil
    t.integer "insert_size"
    t.string "kit_barcode"
    t.bigint "ont_pool_id"
    t.bigint "ont_request_id", null: false
    t.string "state"
    t.bigint "tag_id"
    t.datetime "updated_at", null: false
    t.string "uuid"
    t.float "volume"
    t.index ["ont_pool_id"], name: "index_ont_libraries_on_ont_pool_id"
    t.index ["ont_request_id"], name: "index_ont_libraries_on_ont_request_id"
    t.index ["tag_id"], name: "index_ont_libraries_on_tag_id"
  end

  create_table "ont_min_know_versions", charset: "utf8mb3", force: :cascade do |t|
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.boolean "default", default: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_ont_min_know_versions_on_name", unique: true
  end

  create_table "ont_pools", charset: "utf8mb3", force: :cascade do |t|
    t.float "concentration"
    t.datetime "created_at", null: false
    t.float "final_library_amount"
    t.integer "insert_size"
    t.string "kit_barcode"
    t.bigint "tube_id"
    t.datetime "updated_at", null: false
    t.string "uuid", null: false
    t.float "volume"
    t.index ["tube_id"], name: "index_ont_pools_on_tube_id"
  end

  create_table "ont_requests", charset: "utf8mb3", force: :cascade do |t|
    t.string "cost_code", null: false
    t.datetime "created_at", null: false
    t.bigint "data_type_id", null: false
    t.string "external_study_id", limit: 36, null: false
    t.bigint "library_type_id", null: false
    t.integer "number_of_flowcells", default: 1, null: false
    t.datetime "updated_at", null: false
    t.index ["data_type_id"], name: "index_ont_requests_on_data_type_id"
    t.index ["library_type_id"], name: "index_ont_requests_on_library_type_id"
  end

  create_table "ont_runs", charset: "utf8mb3", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "deactivated_at"
    t.string "experiment_name"
    t.bigint "ont_instrument_id", null: false
    t.bigint "ont_min_know_version_id"
    t.string "rebasecalling_process"
    t.integer "state", default: 0
    t.datetime "updated_at", null: false
    t.string "uuid"
    t.index ["ont_instrument_id"], name: "index_ont_runs_on_ont_instrument_id"
    t.index ["ont_min_know_version_id"], name: "index_ont_runs_on_ont_min_know_version_id"
  end

  create_table "pacbio_libraries", charset: "utf8mb3", force: :cascade do |t|
    t.float "concentration"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "deactivated_at", precision: nil
    t.integer "insert_size"
    t.bigint "pacbio_library_batch_id"
    t.bigint "pacbio_request_id", null: false
    t.string "state"
    t.bigint "tag_id"
    t.string "template_prep_kit_box_barcode"
    t.bigint "tube_id"
    t.datetime "updated_at", precision: nil, null: false
    t.string "uuid"
    t.float "volume"
    t.index ["pacbio_library_batch_id"], name: "index_pacbio_libraries_on_pacbio_library_batch_id"
    t.index ["pacbio_request_id"], name: "index_pacbio_libraries_on_pacbio_request_id"
    t.index ["tag_id"], name: "index_pacbio_libraries_on_tag_id"
    t.index ["tube_id"], name: "index_pacbio_libraries_on_tube_id"
  end

  create_table "pacbio_library_batches", charset: "utf8mb3", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "pacbio_plates", charset: "utf8mb3", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.bigint "pacbio_run_id"
    t.integer "plate_number", null: false
    t.string "sequencing_kit_box_barcode", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "uuid"
    t.index ["pacbio_run_id"], name: "index_pacbio_plates_on_pacbio_run_id"
  end

  create_table "pacbio_pools", charset: "utf8mb3", force: :cascade do |t|
    t.float "concentration"
    t.datetime "created_at"
    t.integer "insert_size"
    t.string "template_prep_kit_box_barcode"
    t.bigint "tube_id", null: false
    t.datetime "updated_at"
    t.float "volume"
    t.index ["tube_id"], name: "index_pacbio_pools_on_tube_id"
  end

  create_table "pacbio_requests", charset: "utf8mb3", force: :cascade do |t|
    t.string "cost_code"
    t.datetime "created_at", precision: nil, null: false
    t.string "estimate_of_gb_required"
    t.string "external_study_id"
    t.string "library_type"
    t.integer "number_of_smrt_cells"
    t.string "source_barcode"
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "pacbio_runs", charset: "utf8mb3", force: :cascade do |t|
    t.text "barcodes_and_concentrations"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "deactivated_at", precision: nil
    t.string "dna_control_complex_box_barcode"
    t.string "name"
    t.bigint "pacbio_smrt_link_version_id"
    t.integer "state", default: 0
    t.integer "system_name", default: 2
    t.datetime "updated_at", precision: nil, null: false
    t.string "uuid"
    t.index ["name"], name: "index_pacbio_runs_on_name", unique: true
    t.index ["pacbio_smrt_link_version_id"], name: "index_pacbio_runs_on_pacbio_smrt_link_version_id"
  end

  create_table "pacbio_smrt_link_option_versions", charset: "utf8mb3", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "pacbio_smrt_link_option_id"
    t.bigint "pacbio_smrt_link_version_id"
    t.datetime "updated_at", null: false
    t.index ["pacbio_smrt_link_option_id"], name: "index_smrt_link_option_versions_on_option_id"
    t.index ["pacbio_smrt_link_version_id"], name: "index_smrt_link_option_versions_on_version_id"
  end

  create_table "pacbio_smrt_link_options", charset: "utf8mb3", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "data_type", default: 0
    t.string "default_value"
    t.string "key", null: false
    t.string "label", null: false
    t.text "select_options"
    t.datetime "updated_at", null: false
    t.json "validations"
    t.index ["key"], name: "index_pacbio_smrt_link_options_on_key", unique: true
  end

  create_table "pacbio_smrt_link_versions", charset: "utf8mb3", force: :cascade do |t|
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.boolean "default", default: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_pacbio_smrt_link_versions_on_name", unique: true
  end

  create_table "pacbio_wells", charset: "utf8mb3", force: :cascade do |t|
    t.string "column"
    t.datetime "created_at", precision: nil, null: false
    t.bigint "pacbio_plate_id"
    t.string "row"
    t.json "smrt_link_options"
    t.datetime "updated_at", precision: nil, null: false
    t.string "uuid"
    t.index ["pacbio_plate_id"], name: "index_pacbio_wells_on_pacbio_plate_id"
  end

  create_table "plates", charset: "utf8mb3", force: :cascade do |t|
    t.string "barcode"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["barcode"], name: "index_plates_on_barcode", unique: true
  end

  create_table "printers", charset: "utf8mb3", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "deactivated_at"
    t.integer "labware_type", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_printers_on_name", unique: true
  end

  create_table "qc_assay_types", charset: "utf8mb3", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "key", null: false
    t.string "label", null: false
    t.string "units"
    t.datetime "updated_at", null: false
    t.integer "used_by"
  end

  create_table "qc_decision_results", charset: "utf8mb3", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "qc_decision_id", null: false
    t.bigint "qc_result_id", null: false
    t.datetime "updated_at", null: false
    t.index ["qc_decision_id"], name: "index_qc_decision_results_on_qc_decision_id"
    t.index ["qc_result_id"], name: "index_qc_decision_results_on_qc_result_id"
  end

  create_table "qc_decisions", charset: "utf8mb3", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "decision_made_by"
    t.string "status"
    t.datetime "updated_at", null: false
  end

  create_table "qc_receptions", charset: "utf8mb3", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "source"
    t.datetime "updated_at", null: false
  end

  create_table "qc_results", charset: "utf8mb3", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "labware_barcode", null: false
    t.bigint "qc_assay_type_id", null: false
    t.bigint "qc_reception_id"
    t.string "sample_external_id", null: false
    t.datetime "updated_at", null: false
    t.string "value", null: false
    t.index ["qc_assay_type_id"], name: "index_qc_results_on_qc_assay_type_id"
    t.index ["qc_reception_id"], name: "index_qc_results_on_qc_reception_id"
  end

  create_table "qc_results_uploads", charset: "utf8mb3", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "csv_data", size: :long
    t.datetime "updated_at", null: false
    t.string "used_by"
  end

  create_table "receptions", charset: "utf8mb3", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "source", null: false
    t.datetime "updated_at", null: false
  end

  create_table "requests", charset: "utf8mb3", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.bigint "reception_id"
    t.bigint "requestable_id"
    t.string "requestable_type"
    t.bigint "sample_id"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["reception_id"], name: "index_requests_on_reception_id"
    t.index ["requestable_type", "requestable_id"], name: "index_requests_on_requestable_type_and_requestable_id"
    t.index ["sample_id"], name: "index_requests_on_sample_id"
  end

  create_table "samples", charset: "utf8mb3", force: :cascade do |t|
    t.string "accession_number", comment: "Accession Number"
    t.string "country_of_origin", comment: "Country of origin"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "date_of_sample_collection", comment: "Date of sample collection"
    t.datetime "deactivated_at", precision: nil
    t.string "donor_id", comment: "Donor Id"
    t.string "external_id"
    t.string "name"
    t.integer "number_of_donors"
    t.string "priority_level", comment: "Priority level e.g. Medium, High etc"
    t.string "public_name", comment: "Public name"
    t.integer "retention_instruction"
    t.string "sanger_sample_id", comment: "Sanger sample id"
    t.string "species"
    t.string "supplier_name", comment: "Supplier name"
    t.string "taxon_id", comment: "Taxon Id"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["external_id"], name: "index_samples_on_external_id", unique: true
    t.index ["name", "external_id", "species"], name: "index_samples_on_name_and_external_id_and_species"
    t.index ["name"], name: "index_samples_on_name", unique: true
  end

  create_table "tag_sets", charset: "utf8mb3", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.datetime "created_at", precision: nil, null: false
    t.string "name"
    t.integer "pipeline", null: false
    t.integer "sample_sheet_behaviour", default: 0, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "uuid"
  end

  create_table "tag_taggables", charset: "utf8mb3", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "tag_id"
    t.bigint "taggable_id"
    t.string "taggable_type"
    t.datetime "updated_at", null: false
    t.index ["tag_id"], name: "index_tag_taggables_on_tag_id"
    t.index ["taggable_type", "taggable_id"], name: "index_tag_taggables_on_taggable_type_and_taggable_id"
  end

  create_table "tags", charset: "utf8mb3", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.string "group_id"
    t.string "oligo"
    t.string "oligo_reverse"
    t.bigint "tag_set_id"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["group_id", "tag_set_id"], name: "index_tags_on_group_id_and_tag_set_id", unique: true
    t.index ["oligo", "tag_set_id"], name: "index_tags_on_oligo_and_tag_set_id", unique: true
    t.index ["tag_set_id"], name: "index_tags_on_tag_set_id"
  end

  create_table "tubes", charset: "utf8mb3", force: :cascade do |t|
    t.string "barcode"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["barcode"], name: "index_tubes_on_barcode", unique: true
  end

  create_table "wells", charset: "utf8mb3", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "plate_id"
    t.string "position"
    t.datetime "updated_at", null: false
    t.index ["plate_id", "position"], name: "index_wells_on_plate_id_and_position", unique: true
    t.index ["plate_id"], name: "index_wells_on_plate_id"
  end

  create_table "workflow_steps", charset: "utf8mb3", force: :cascade do |t|
    t.string "code"
    t.datetime "created_at", null: false
    t.string "stage"
    t.datetime "updated_at", null: false
    t.bigint "workflow_id", null: false
    t.index ["code"], name: "index_workflow_steps_on_code", unique: true
    t.index ["workflow_id"], name: "index_workflow_steps_on_workflow_id"
  end

  create_table "workflows", charset: "utf8mb3", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.integer "pipeline"
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_workflows_on_name", unique: true
  end

  add_foreign_key "annotations", "annotation_types"
  add_foreign_key "ont_flowcells", "ont_pools"
  add_foreign_key "ont_flowcells", "ont_runs"
  add_foreign_key "ont_requests", "data_types"
  add_foreign_key "ont_requests", "library_types"
  add_foreign_key "ont_runs", "ont_instruments"
  add_foreign_key "ont_runs", "ont_min_know_versions"
  add_foreign_key "pacbio_libraries", "pacbio_library_batches"
  add_foreign_key "pacbio_libraries", "pacbio_requests"
  add_foreign_key "pacbio_libraries", "tubes"
  add_foreign_key "pacbio_pools", "tubes"
  add_foreign_key "pacbio_runs", "pacbio_smrt_link_versions"
  add_foreign_key "pacbio_smrt_link_option_versions", "pacbio_smrt_link_options"
  add_foreign_key "pacbio_smrt_link_option_versions", "pacbio_smrt_link_versions"
  add_foreign_key "qc_decision_results", "qc_decisions"
  add_foreign_key "qc_decision_results", "qc_results"
  add_foreign_key "qc_results", "qc_assay_types"
  add_foreign_key "qc_results", "qc_receptions"
  add_foreign_key "requests", "receptions"
  add_foreign_key "workflow_steps", "workflows"
  add_foreign_key "api_keys", "api_applications"
end
