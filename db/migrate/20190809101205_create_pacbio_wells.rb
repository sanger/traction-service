class CreatePacbioWells < ActiveRecord::Migration[5.2]
  def change
    create_table :pacbio_wells do |t|
      t.belongs_to :pacbio_plate, index: true
      t.string :row
      t.string :column
      t.decimal :movie_time, precision: 3, scale: 1
      t.integer :insert_size
      t.float :on_plate_loading_concentration
      t.string :comment
      t.string :uuid
      t.integer :sequencing_mode
      t.timestamps
    end
  end
end
