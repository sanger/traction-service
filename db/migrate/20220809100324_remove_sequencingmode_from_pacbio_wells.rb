class RemoveSequencingmodeFromPacbioWells < ActiveRecord::Migration[7.0]
  # This column is no longer needed and the data is no longer required
  def change
    remove_column :pacbio_wells, :sequencing_mode, :integer
  end
end
