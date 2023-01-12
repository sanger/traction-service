class CreateNewOntInstruments < ActiveRecord::Migration[7.0]
  def change
    create_table :ont_instruments do |t|
      t.string :name, null:false, index: {unique: true}  # name such as GXB02004
      t.integer :instrument_type, null: false   # enum { MinION: 0, GridION: 1, PromethION: 2 }
      t.integer :max_number_of_flowcells, null: false # Up to MinION: 1, GridION: 5, PromethION: 48 (24 used)
      t.string :uuid  # included in the model
      t.timestamps
    end
  end
end
