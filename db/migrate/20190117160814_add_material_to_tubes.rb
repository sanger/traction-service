class AddMaterialToTubes < ActiveRecord::Migration[5.2]
  def change
    add_reference :tubes, :material, polymorphic: true
  end
end
