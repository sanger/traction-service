class RemoveInsertSizeFromPacbioRunWell < ActiveRecord::Migration[6.0]
  def change
    remove_column :pacbio_wells, :insert_size, :integer
  end
end
