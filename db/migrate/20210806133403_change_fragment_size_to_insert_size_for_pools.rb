class ChangeFragmentSizeToInsertSizeForPools < ActiveRecord::Migration[6.0]
  def change
    rename_column :pacbio_pools, :fragment_size, :insert_size
  end
end
