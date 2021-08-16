class ChangeFragmentSizeToInsertSizeForLibraries < ActiveRecord::Migration[6.0]
  def change
    rename_column :pacbio_libraries, :fragment_size, :insert_size
  end
end
