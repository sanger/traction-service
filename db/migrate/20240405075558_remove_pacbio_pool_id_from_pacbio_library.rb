# frozen_string_literal: true

# Remove the Pacbio libraries with a pacbio_pool_id 
# and remove the pacbio_pool_id column from the pacbio_libraries table
class RemovePacbioPoolIdFromPacbioLibrary < ActiveRecord::Migration[7.1]
  def up
    # Remove all libraries that have a pool_id as they have been replaced by aliquots
    Pacbio::Library.transaction do
      Pacbio::Library.where.not(pacbio_pool_id: nil).each do |library|
        library.delete
      end
    end

    # Remove the column from the table
    remove_reference :pacbio_libraries, :pacbio_pool, null: true, foreign_key: true
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
