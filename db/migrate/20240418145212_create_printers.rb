class CreatePrinters < ActiveRecord::Migration[7.1]
  def change
    create_table :printers do |t|
      t.string :name, null: false
      t.integer :labware_type, null: false
      t.datetime :deactivated_at
      t.timestamps
    end
    add_index :printers, :name, unique: true
  end
end
