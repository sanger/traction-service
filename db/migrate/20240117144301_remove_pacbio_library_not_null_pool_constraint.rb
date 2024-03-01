class RemovePacbioLibraryNotNullPoolConstraint < ActiveRecord::Migration[7.1]
  def change
    change_column_null :pacbio_libraries, :pacbio_pool_id, true
  end
end
