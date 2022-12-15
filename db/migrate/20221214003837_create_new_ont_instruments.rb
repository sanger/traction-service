class CreateNewOntInstruments < ActiveRecord::Migration[7.0]
  def change
    create_table :ont_instruments do |t|
      t.integer :name, null: false, index: {unique: true}  # enum { MinIon: 0, GridIon: 1, PromethIon: 2 }
      t.integer :max_number_of_flowcells, null: false
      t.timestamps
    end
  end
end
