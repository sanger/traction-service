class AddRelationshipsToPacbioLibraries < ActiveRecord::Migration[6.0]
  def change
    add_reference :pacbio_libraries, :pacbio_request, index: true
    add_reference :pacbio_libraries, :tag, index: true
    add_reference :pacbio_libraries, :pacbio_pool, index: true
  end
end
