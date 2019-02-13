class CreateRuns < ActiveRecord::Migration[5.2]
  def change
    create_table :runs do |t|
      t.integer :state
      t.datetime :deactivated_at

      t.timestamps
    end
  end
end
