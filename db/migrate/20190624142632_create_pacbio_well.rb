class CreatePacbioWell < ActiveRecord::Migration[5.2]
  def change
    create_table :pacbio_wells do |t|
      t.belongs_to :pacbio_plate, index: true
      t.string :row
      t.string :column
      t.decimal :movie_time
      t.integer :insert_size
      t.float :on_plate_loading_concentration
      t.string :comment
      t.timestamps
    end
  end
end
