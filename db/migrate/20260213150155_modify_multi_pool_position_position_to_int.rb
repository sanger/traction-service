class ModifyMultiPoolPositionPositionToInt < ActiveRecord::Migration[8.1]
  def change
    change_column :multi_pool_positions, :position, :integer
  end
end
