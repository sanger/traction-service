class AddMultiColumnIndexToSamples < ActiveRecord::Migration[6.0]
  def change
    add_index :samples, [:name, :external_id, :species]
  end
end
