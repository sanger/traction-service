class AddMultiPoolTables < ActiveRecord::Migration[8.0]
  def change
    create_table :multi_pools do |t|
      t.integer :pool_method, null: false # enum to store pool method e.g. "Plate", "TubeRack" etc.
      t.integer :pipeline, null: false # e.g. "Ont", "Pacbio"
      t.timestamps
    end

    create_table :multi_pool_positions do |t|
      t.string :position, null: false # e.g. "A1", "B2", etc.
      t.belongs_to :pool, polymorphic: true, index: { unique: true } # e.g. Ont::Pool or Pacbio::Pool
      t.belongs_to :multi_pool, index: true
      t.timestamps
    end
  end
end
