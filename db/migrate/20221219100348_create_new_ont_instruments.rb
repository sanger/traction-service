class CreateNewOntInstruments < ActiveRecord::Migration[7.0]
  def change
    create_table :ont_instruments do |t|
      t.string :name, null:false, index: {unique: true}  # name such as GXB02004
      t.integer :instrument_type, null: false   # enum { MinIon: 0, GridIon: 1, PromethIon: 2 }
      t.integer :max_number_of_flowcells, null: false # Up to MinIon: 1, GridIon: 5, PromethIon: 48 (24 used)
      t.timestamps
    end
  end
end
