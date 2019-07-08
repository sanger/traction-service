class AddSystemNameToPacbioRun < ActiveRecord::Migration[5.2]
  def change
    add_column :pacbio_runs, :system_name, :integer, default: 0
  end
end
