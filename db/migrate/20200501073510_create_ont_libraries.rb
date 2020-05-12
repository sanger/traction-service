class CreateOntLibraries < ActiveRecord::Migration[6.0]
  def change
    create_table :ont_libraries do |t|
      t.string :name
      t.integer :pool
      t.integer :pool_size
      t.timestamps
    end

    change_table :ont_requests do |t|
      t.belongs_to :ont_library, index: true
    end
  end
end
