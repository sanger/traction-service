class UpdatePacbioLibraryRelationships < ActiveRecord::Migration[5.2]
  def change
    change_table :pacbio_libraries do |t|
      t.remove_references :sample
    end

    change_table :pacbio_libraries do |t|
      t.belongs_to :pacbio_request
    end
  end
end
