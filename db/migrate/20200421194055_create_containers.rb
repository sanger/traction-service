class CreateContainers < ActiveRecord::Migration[6.0]
  def change
    create_table :containers do |t|
      t.belongs_to :receptacle, polymorphic: true, index: true
      t.belongs_to :material, polymorphic: true, index: true
      t.timestamps
    end
  end
end
