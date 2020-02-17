class AddSourceBarcodeToRequest < ActiveRecord::Migration[5.2]
  def change
    add_column :pacbio_requests, :source_barcode, :string
  end
end
