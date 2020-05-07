class CreateOntFlowcells < ActiveRecord::Migration[6.0]
  def change
    create_table :ont_flowcells do |t|
      t.integer :position
      t.string :uuid
      t.belongs_to :ont_run, index: true
      t.timestamps
    end

    change_table :ont_libraries do |t|
      t.belongs_to :ont_flowcell, null: true, index: true
    end
  end
end
