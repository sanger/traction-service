class CreateLibraries < ActiveRecord::Migration[5.2]
  def change
    create_table :libraries do |t|
      t.string :state
      t.belongs_to :sample, index: true, foreign_key: true
      t.timestamps
    end
  end
end
