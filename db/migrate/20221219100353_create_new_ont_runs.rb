class CreateNewOntRuns < ActiveRecord::Migration[7.0]
  def change
    create_table :ont_runs do |t|
      t.belongs_to :ont_instrument, null: false, foreign_key: true
      t.string :experiment_name
      t.integer :state, default: 0
      t.datetime :deactivated_at
      t.string :uuid  # included in the model
      t.timestamps
    end
  end
end
