# frozen_string_literal: true

# We avoid creating duplicate resources, so lets an in index to help the reception
class AddMissingIndicies < ActiveRecord::Migration[7.0]
  def change
    add_index :plates, :barcode, unique: true
    add_index :tubes, :barcode, unique: true
    add_index :wells, %i[plate_id position], unique: true
    add_index :samples, :external_id, unique: true
  end
end
