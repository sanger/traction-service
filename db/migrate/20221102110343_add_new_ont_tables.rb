class AddNewOntTables < ActiveRecord::Migration[7.0]
  def change
    create_table :ont_libraries do |t|
      t.integer :kit_barcode
      t.float :volume
      t.float :concentration
      t.integer :insert_size
      t.string :uuid
      t.timestamps
      t.string :state
      t.datetime :deactivated_at, precision: nil
      t.belongs_to :ont_request, index: true, null: false
      t.belongs_to :tag, index: true
      t.belongs_to :ont_pool, index: true
    end

    create_table :ont_pools do |t|
      t.integer :kit_barcode
      t.float :volume
      t.float :concentration
      t.integer :insert_size
      t.float :final_library_amount
      t.timestamps
      t.belongs_to :tube, index: true
    end
  end
end
