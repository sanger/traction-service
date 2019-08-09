class CreatePacbioRequestLibraries < ActiveRecord::Migration[5.2]
   def change
    create_table :pacbio_request_libraries do |t|
      t.belongs_to :pacbio_request, index: true
      t.belongs_to :pacbio_library, index: true
      t.belongs_to :tag, index: true
    end
  end
end
