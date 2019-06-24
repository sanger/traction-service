class CreatePacbioLibraries < ActiveRecord::Migration[5.2]
  def change
    create_table :pacbio_libraries do |t|
      t.decimal :volume
      t.decimal :concentration
      t.string :library_kit_barcode
      t.integer :fragment_size
      t.timestamps
    end
  end
end
