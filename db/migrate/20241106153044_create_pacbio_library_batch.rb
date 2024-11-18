class CreatePacbioLibraryBatch < ActiveRecord::Migration[7.2]
  def change
    create_table :pacbio_library_batches do |t|
      t.timestamps
    end

    add_reference :pacbio_libraries, :pacbio_library_batch, index: true, foreign_key: true, null: true
  end
end
