class UpdatePacbioWellsAndLibraryRelationship < ActiveRecord::Migration[5.2]
  def change
    change_table :pacbio_libraries do |t|
      t.remove_references :pacbio_well
    end

    change_table :pacbio_wells do |t|
      t.belongs_to :pacbio_library
    end

  end
end
