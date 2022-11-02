class AddNewOntTables < ActiveRecord::Migration[7.0]
  def change
    create_table :ont_libraries do |t|
      t.float :volume
      t.integer :kit_number
      t.string :uuid
      t.timestamps
      t.belongs_to :ont_request, index: true, null: false
      t.belongs_to :tag, index: true
      t.belongs_to :ont_pool, index: true
    end

    create_table :ont_pools do |t|
      t.float :volume
      t.integer :kit_number
      t.timestamps
      t.belongs_to :tube, index: true
    end
  end
end
