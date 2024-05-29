class AddActiveToTagSets < ActiveRecord::Migration[7.1]
  def change
    add_column :tag_sets, :active, :boolean, default: true, null: false
  end
end
