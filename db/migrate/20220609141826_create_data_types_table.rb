# frozen_string_literal: true

# Will be associated with ONT requests, but adding a pipline key to allow
# us to extend the system easily in future. Maybe a bit Yagni, but simple
# enough
class CreateDataTypesTable < ActiveRecord::Migration[7.0]
  def change
    create_table :data_types do |t|
      t.string :name, null: false
      t.integer :pipeline, null: false, index: true

      t.timestamps
    end
  end
end
