class CreateOntRuns < ActiveRecord::Migration[6.0]
  def change
    create_table :ont_runs do |t|
      t.integer :state, default: 0
      t.datetime :deactivated_at
      t.timestamps
    end
  end
end
