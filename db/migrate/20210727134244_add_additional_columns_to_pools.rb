# frozen_string_literal: true

# Most of the library level information is also present at the pool level
class AddAdditionalColumnsToPools < ActiveRecord::Migration[6.0]
  def change
    change_table :pacbio_pools do |t|
      t.float 'volume'
      t.float 'concentration'
      t.string 'template_prep_kit_box_barcode'
      t.integer 'fragment_size'
      t.timestamps null: true

      change_column_null 'pacbio_pools', 'tube_id', false
      t.foreign_key :tubes
    end
  end
end
