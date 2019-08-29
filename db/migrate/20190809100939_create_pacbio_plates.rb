class CreatePacbioPlates < ActiveRecord::Migration[5.2]
   def change
    create_table :pacbio_plates do |t|
      t.belongs_to :pacbio_run, index: true
      t.string :uuid
      t.string :barcode
      t.timestamps
    end
  end
end
