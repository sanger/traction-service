class CreateChips < ActiveRecord::Migration[5.2]
  def change
    create_table :chips do |t|
      t.string :barcode
    end
  end
end
