# frozen_string_literal: true

# Now we've created out supporting tables, we can build our requests table,
# complete with foreign keys
class CreateOntRequestsTable < ActiveRecord::Migration[7.0]
  def change
    create_table :ont_requests do |t|
      t.references :library_type, foreign_key: true, null: false
      t.references :data_type, foreign_key: true, null: false
      t.integer :number_of_flowcells, null: false, default: 1
      t.timestamps
      # We *could* encode the uuid as a binary. It is more compact, and has
      # performance advantages, especially when indexed. However maintaining
      # consistency and simplicity for now
      t.string :external_study_id, limit: 36, null: false
      t.string :cost_code, null: false
    end
  end
end
