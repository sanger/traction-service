class CreateTubes < ActiveRecord::Migration[5.2]
  def change
    create_table :tubes do |t|
      t.string :barcode
      t.belongs_to :material, polymorphic: true, index: true
      t.timestamps
    end
  end
end
