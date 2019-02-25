class RemoveFlowcellReferenceFromLibraries < ActiveRecord::Migration[5.2]
  def change
    remove_column :libraries, :flowcell_id
  end
end
