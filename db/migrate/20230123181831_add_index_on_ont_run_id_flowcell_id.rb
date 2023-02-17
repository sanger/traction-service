class AddIndexOnOntRunIdFlowcellId < ActiveRecord::Migration[7.0]
  def change
    add_index :ont_flowcells, [:ont_run_id, :flowcell_id], unique: true
  end
end
