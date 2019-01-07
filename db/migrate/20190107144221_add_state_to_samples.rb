class AddStateToSamples < ActiveRecord::Migration[5.2]
  def change
    add_column :samples, :state, :string
  end
end
