class RemoveRelationshipsFromPacbioWells < ActiveRecord::Migration[5.2]
  def change
    change_table :pacbio_wells do |t|
      t.remove_references :pacbio_library
    end
  end
end
