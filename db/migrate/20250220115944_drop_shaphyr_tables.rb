class DropShaphyrTables < ActiveRecord::Migration[7.2]
  def up
    drop_table :saphyr_chips, if_exists: true
    drop_table :saphyr_enzymes, if_exists: true
    drop_table :saphyr_flowcells, if_exists: true
    drop_table :saphyr_libraries, if_exists: true
    drop_table :saphyr_requests, if_exists: true
    drop_table :saphyr_runs, if_exists: true
  end

  def down
    create_table "saphyr_chips", charset: "utf8mb3", force: :cascade do |t|
      t.string "barcode"
      t.string "serial_number"
      t.datetime "created_at", precision: nil, null: false
      t.datetime "updated_at", precision: nil, null: false
      t.bigint "saphyr_run_id"
      t.index ["saphyr_run_id"], name: "index_saphyr_chips_on_saphyr_run_id"
    end

    create_table "saphyr_enzymes", charset: "utf8mb3", force: :cascade do |t|
      t.string "name"
      t.datetime "created_at", precision: nil, null: false
      t.datetime "updated_at", precision: nil, null: false
      t.index ["name"], name: "index_saphyr_enzymes_on_name", unique: true
    end

    create_table "saphyr_flowcells", charset: "utf8mb3", force: :cascade do |t|
      t.integer "position"
      t.datetime "created_at", precision: nil, null: false
      t.datetime "updated_at", precision: nil, null: false
      t.bigint "saphyr_chip_id"
      t.bigint "saphyr_library_id"
      t.index ["saphyr_chip_id"], name: "index_saphyr_flowcells_on_saphyr_chip_id"
      t.index ["saphyr_library_id"], name: "index_saphyr_flowcells_on_saphyr_library_id"
    end

    create_table "saphyr_libraries", charset: "utf8mb3", force: :cascade do |t|
      t.string "state"
      t.datetime "deactivated_at", precision: nil
      t.datetime "created_at", precision: nil, null: false
      t.datetime "updated_at", precision: nil, null: false
      t.bigint "saphyr_enzyme_id"
      t.bigint "saphyr_request_id"
      t.index ["saphyr_enzyme_id"], name: "index_saphyr_libraries_on_saphyr_enzyme_id"
      t.index ["saphyr_request_id"], name: "index_saphyr_libraries_on_saphyr_request_id"
    end

    create_table "saphyr_requests", charset: "utf8mb3", force: :cascade do |t|
      t.string "external_study_id"
      t.datetime "created_at", precision: nil, null: false
      t.datetime "updated_at", precision: nil, null: false
    end

    create_table "saphyr_runs", charset: "utf8mb3", force: :cascade do |t|
      t.integer "state", default: 0
      t.string "name"
      t.datetime "deactivated_at", precision: nil
      t.datetime "created_at", precision: nil, null: false
      t.datetime "updated_at", precision: nil, null: false
    end
  end
end
