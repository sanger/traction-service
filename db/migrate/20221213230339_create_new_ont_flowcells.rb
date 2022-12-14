class CreateNewOntFlowcells < ActiveRecord::Migration[7.0]
  def change
    create_table :ont_flowcells do |t|
      t.string :barcode # flowcell_id in traction-legacy
      t.integer :position # unique among others of the run
      t.string :uuid  # included in the model
      t.belongs_to :ont_run, index: true
      t.belongs_to :ont_pool, index: true # pool instead of library
      t.timestamps
    end
    # The model validates the unique together constraint.
    add_index :ont_flowcells, [:ont_run_id, :position], unique: true
  end
end
