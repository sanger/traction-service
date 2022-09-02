class CreateQcResults < ActiveRecord::Migration[7.0]
  def change
    create_table :qc_results do |t|
      t.string :labware_barcode, null: false
      t.string :sample_external_id, null: false
      t.references :qc_assay_type, null: false, foreign_key: true
      t.string :value, null:false

      t.timestamps
    end
  end
end
