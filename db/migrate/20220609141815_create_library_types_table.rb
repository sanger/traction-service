# frozen_string_literal: true

# We'll probably want to migrate the pacbio requests to use this table as well
class CreateLibraryTypesTable < ActiveRecord::Migration[7.0]
  def change
    create_table :library_types do |t|
      t.string :name, null: false
      t.integer :pipeline, null: false, index: true

      t.timestamps
    end
  end
end
