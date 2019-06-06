class CreateChips < ActiveRecord::Migration[5.2]
  def change
    create_table :chips do |t|
      t.string :barcode
      t.string :serial_number
      t.belongs_to :run, index: true
      t.timestamps
    end
  end
end
