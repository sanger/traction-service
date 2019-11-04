class AddStateToPacbioRuns < ActiveRecord::Migration[5.2]
  def change
    add_column :pacbio_runs, :state, :integer, default: 0
    add_column :pacbio_runs, :deactivated_at, :datetime
  end
end
