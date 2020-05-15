class CreateOntFlowcells < ActiveRecord::Migration[6.0]
  def change
    create_table :ont_flowcells do |t|
      t.integer :position
      t.string :uuid
      t.belongs_to :ont_run, index: true
      t.belongs_to :ont_library, index: true
      t.timestamps
    end
  end
end
