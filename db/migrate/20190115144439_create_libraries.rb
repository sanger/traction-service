class CreateLibraries < ActiveRecord::Migration[5.2]
  def change
    create_table :libraries do |t|
      t.string :state
      t.belongs_to :sample, index: true
      t.belongs_to :enzyme, index: true
      t.datetime :deactivated_at
      t.timestamps
    end
  end
end
