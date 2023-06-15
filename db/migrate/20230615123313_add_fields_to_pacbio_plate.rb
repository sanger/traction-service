class AddFieldsToPacbioPlate < ActiveRecord::Migration[7.0]
  def change
    add_column :pacbio_plates, :plate_number, :integer, null: false
    add_column :pacbio_plates, :sequencing_kit_box_barcode, :string, null: false
  end
end
