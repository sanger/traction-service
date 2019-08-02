class RemoveRelationshipsFromPacbioLibraries < ActiveRecord::Migration[5.2]
  def change
    change_table :pacbio_libraries do |t|
      t.remove_references :tag
      t.remove_references :request
    end
  end
end
