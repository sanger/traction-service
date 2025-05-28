class CreateAnnotationTypes < ActiveRecord::Migration[8.0]
  def change
    create_table :annotation_types do |t|
      t.string :name, null: false
      t.timestamps
    end
    add_index :annotation_types, :name, unique: true
  end
end
