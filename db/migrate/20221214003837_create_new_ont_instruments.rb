class CreateNewOntInstruments < ActiveRecord::Migration[7.0]
  def change
    create_table :ont_instruments do |t|
      t.string :name, null: false, index: {unique: true}  # unique name of device
      t.integer :max_number_of_flowcells, null: false
      t.timestamps
    end
  end
end
