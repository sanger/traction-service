class RemoveBarcodeColumnInPacBioPlate < ActiveRecord::Migration[5.2]
  def change
      remove_column :pacbio_plates, :barcode, :string
  end
end
