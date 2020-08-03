class AddMultiColumnIndexToOntFlowcells < ActiveRecord::Migration[6.0]
  def change
    add_index :ont_flowcells, [:position, :ont_run_id], unique: true
  end
end
