class DropOldOntTables < ActiveRecord::Migration[7.0]
  def up
    drop_table :ont_runs
    drop_table :ont_libraries
    drop_table :ont_flowcells
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
