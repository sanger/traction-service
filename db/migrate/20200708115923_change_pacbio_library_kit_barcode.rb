class ChangePacbioLibraryKitBarcode < ActiveRecord::Migration[6.0]
  def change
    rename_column :pacbio_libraries, :library_kit_barcode, :template_prep_kit_box_barcode
  end
end
