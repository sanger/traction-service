class ChangeTag < ActiveRecord::Migration[5.2]
  def change
    change_table :tags do |t|
      t.belongs_to :tag_set
      t.remove :set_name
    end
  end
end
