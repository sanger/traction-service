class DropSaphyrTables < ActiveRecord::Migration[7.2]
  def up
    drop_table :saphyr_chips
    drop_table :saphyr_enzymes
    drop_table :saphyr_flowcells
    drop_table :saphyr_libraries
    drop_table :saphyr_requests
    drop_table :saphyr_runs
  end

  def down
      fail ActiveRecord::IrreversibleMigration
  end
end
