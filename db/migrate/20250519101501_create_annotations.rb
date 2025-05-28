class CreateAnnotations < ActiveRecord::Migration[8.0]
  def change
    create_table :annotations do |t|
      t.belongs_to :annotation_type, null: false, foreign_key: true
      t.belongs_to :annotatable, polymorphic: true, null: false
      t.string :comment, null: false, limit: 500
      t.string :user, null: false, limit: 10
      t.timestamps
    end
  end
end
