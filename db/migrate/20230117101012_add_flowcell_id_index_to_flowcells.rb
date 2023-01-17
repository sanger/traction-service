class AddFlowcellIdIndexToFlowcells < ActiveRecord::Migration[7.0]
  def change
    add_index :ont_flowcells, :flowcell_id, unique: true
  end
end
