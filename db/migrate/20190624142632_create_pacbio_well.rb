class CreatePacbioWell < ActiveRecord::Migration[5.2]
  def change
    create_table :pacbio_wells do |t|
      t.belongs_to :pacbio_library, index: true
      t.belongs_to :pacbio_plate, index: true
      t.decimal :movie_time
      t.integer :insert_size
      t.integer :sequencing_mode
      t.float :on_plate_loading_concentration
      t.timestamps
    end
  end
end
