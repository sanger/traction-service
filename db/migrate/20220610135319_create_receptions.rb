# frozen_string_literal: true

# Builds the receptions table.
# We currently only have the single attribute 'source' which
# can be used to track where the reception came from.
class CreateReceptions < ActiveRecord::Migration[7.0]
  def change
    create_table :receptions do |t|
      t.string :source, null: false

      t.timestamps
    end
  end
end
