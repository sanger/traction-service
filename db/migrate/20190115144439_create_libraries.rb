class CreateLibraries < ActiveRecord::Migration[5.2]
  def change
    create_table :libraries do |t|
      t.string :state
      t.belongs_to :sample, foreign_key: true
      t.belongs_to :enzyme, foreign_key: true
      t.datetime :deactivated_at
      t.timestamps
    end
  end
end
