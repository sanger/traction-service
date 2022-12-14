class CreateNewOntRuns < ActiveRecord::Migration[7.0]
  def change
    create_table :ont_runs do |t|
      t.belongs_to :ont_instrument
      t.string :experiment_name
      t.integer :state, default: 0
      t.datetime :deactivated_at
      t.timestamps
    end
  end
end
