class CreateNewOntInstruments < ActiveRecord::Migration[7.0]
  def change
    # This table should be populated from a config file.
    # XXX: Should we have a default flag as a column for runs?
    # XXX: Should we have an active flag as a column to disable it?
    create_table :ont_instruments do |t|
      t.string :name, null: false, index: {unique: true}  # unique name of device
      t.integer :max_number, null: false # Max number of flowcells
      t.timestamps
    end
  end
end
