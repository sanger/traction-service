class CreatePlates < ActiveRecord::Migration[6.0]
  def change
    create_table :plates do |t|
      t.string :barcode
      t.timestamps
    end
  end
end
