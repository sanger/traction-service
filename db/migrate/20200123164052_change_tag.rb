class ChangeTag < ActiveRecord::Migration[5.2]
  def up
    change_table :tags do |t|
      t.belongs_to :tag_set
      t.remove :set_name
    end
  end

  def down
    change_table :tags do |t|
      t.column :set_name, :string
      t.remove_references :tag_set
    end
  end
end
