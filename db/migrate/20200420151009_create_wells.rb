class CreateWells < ActiveRecord::Migration[6.0]
  def change
    create_table :wells do |t|
      t.string :position
      t.belongs_to :plate, index: true
      t.belongs_to :material, polymorphic: true, index: true
      t.timestamps
    end
  end
end
