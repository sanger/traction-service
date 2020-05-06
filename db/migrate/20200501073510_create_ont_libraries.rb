class CreateOntLibraries < ActiveRecord::Migration[6.0]
  def change
    create_table :ont_libraries do |t|
      t.string :name
      t.integer :pool
      t.integer :pool_size
      t.timestamps
    end
  end
end
