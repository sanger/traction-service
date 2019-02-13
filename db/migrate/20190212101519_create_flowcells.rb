class CreateFlowcells < ActiveRecord::Migration[5.2]
  def change
    create_table :flowcells do |t|
      t.integer :position
      t.timestamps
    end
  end
end
