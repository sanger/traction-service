class RemoveSequencingKitBoxBarcodeColumnFromPacbioRuns < ActiveRecord::Migration[7.2]
  def change
    remove_column :pacbio_runs, :sequencing_kit_box_barcode
  end
end
