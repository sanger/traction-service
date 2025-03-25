class RenamePacbioRunCommentsToBarcodesAndConcentrations < ActiveRecord::Migration[7.2]
  def change
    rename_column :pacbio_runs, :comments, :barcodes_and_concentrations
  end
end
