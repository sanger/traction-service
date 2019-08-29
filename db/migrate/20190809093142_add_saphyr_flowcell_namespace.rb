class AddSaphyrFlowcellNamespace < ActiveRecord::Migration[5.2]
  def change
    rename_table :flowcells, :saphyr_flowcells
  end
end
