class RemoveStateFromSamples < ActiveRecord::Migration[5.2]
  def change
    remove_column :samples, :state
  end
end
