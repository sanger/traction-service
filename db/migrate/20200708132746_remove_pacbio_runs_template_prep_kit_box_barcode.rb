class RemovePacbioRunsTemplatePrepKitBoxBarcode < ActiveRecord::Migration[6.0]
  def change
    remove_column :pacbio_runs, :template_prep_kit_box_barcode
  end
end
