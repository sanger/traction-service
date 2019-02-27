class CreateRuns < ActiveRecord::Migration[5.2]
  def change
    create_table :runs do |t|
      t.integer :state, default: 0
      t.datetime :deactivated_at
      t.belongs_to :chip, foreign_key: true
      t.timestamps
    end
  end
end
