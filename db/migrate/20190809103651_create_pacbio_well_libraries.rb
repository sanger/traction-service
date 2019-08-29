class CreatePacbioWellLibraries < ActiveRecord::Migration[5.2]
  def change
    create_table :pacbio_well_libraries do |t|
      t.belongs_to :pacbio_well, index: true
      t.belongs_to :pacbio_library, index: true
    end
  end
  
end
