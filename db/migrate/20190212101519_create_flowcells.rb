class CreateFlowcells < ActiveRecord::Migration[5.2]
  def change
    create_table :flowcells do |t|
      t.integer :position
      t.belongs_to :library, index: true
      t.belongs_to :chip, index: true
      t.timestamps
    end
  end
end
