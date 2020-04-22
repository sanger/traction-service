class CreateContainerMaterials < ActiveRecord::Migration[6.0]
  def change
    create_table :container_materials do |t|
      t.belongs_to :container, polymorphic: true, index: true
      t.belongs_to :material, polymorphic: true, index: true
      t.timestamps
    end
  end
end
