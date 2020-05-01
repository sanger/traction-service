class CreateOntLibraries < ActiveRecord::Migration[6.0]
  def change
    create_table :ont_libraries do |t|
      t.string :plate_barcode
      t.integer :pool
      t.string :well_range
      t.integer :pool_size
      t.timestamps
    end

    change_table :ont_requests do |t|
      t.belongs_to :ont_library, index: true
    end
  end
end
