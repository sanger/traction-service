class CreateTags < ActiveRecord::Migration[5.2]
  def change
    create_table :tags do |t|
      t.string :oligo
      t.integer :group_id
      t.string :set_name
      t.timestamps
    end
  end
end
