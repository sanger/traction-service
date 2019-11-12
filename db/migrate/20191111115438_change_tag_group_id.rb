class ChangeTagGroupId < ActiveRecord::Migration[5.2]
  def change
    change_column :tags, :group_id, :string
  end
end
