class CreateWorkflows < ActiveRecord::Migration[7.2]
  def change
    create_table :workflows do |t|
      t.string :name
      t.integer :pipeline

      t.timestamps
    end
    add_index :workflows, :name, unique: true
  end
end
