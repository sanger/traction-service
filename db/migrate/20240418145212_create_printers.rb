class CreatePrinters < ActiveRecord::Migration[7.1]
  def change
    create_table :printers do |t|
      t.string :name
      t.integer :labware_type
      t.boolean :active

      t.timestamps
    end
  end
end
