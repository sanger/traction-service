class AddLibraryReferenceToFlowcells < ActiveRecord::Migration[5.2]
  def change
    add_reference :flowcells, :library, foreign_key: true
  end
end
