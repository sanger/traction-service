class CreateTagTaggables < ActiveRecord::Migration[6.0]
  def change
    create_table :tag_taggables do |t|
      t.belongs_to :taggable, polymorphic: true, index: true
      t.belongs_to :tag, index: true
      t.timestamps
    end
  end
end
