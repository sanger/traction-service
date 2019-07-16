class MoveSequencingModeFromRunToWell < ActiveRecord::Migration[5.2]
  def change
    remove_column :pacbio_runs, :sequencing_mode
    add_column :pacbio_wells, :sequencing_mode, :integer
  end
end
