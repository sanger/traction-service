class CreateFlowcells < ActiveRecord::Migration[5.2]
  def change
    create_table :flowcells do |t|
      t.integer :position
      t.belongs_to :library, foreign_key: true
      t.references :chip, foreign_key: true
      t.timestamps
    end
  end
end
