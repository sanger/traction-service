class CreateTubes < ActiveRecord::Migration[5.2]
  def change
    create_table :tubes do |t|
      t.string :barcode
    end
  end
end
