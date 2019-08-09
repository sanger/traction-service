class CreatePacbioRuns < ActiveRecord::Migration[5.2]
  def change
    create_table :pacbio_runs do |t|
      t.string :name
      t.string :template_prep_kit_box_barcode
      t.string :binding_kit_box_barcode
      t.string :sequencing_kit_box_barcode
      t.string :dna_control_complex_box_barcode
      t.string :comments
      t.string :uuid
      t.integer :system_name, default: 0
      t.timestamps
    end
  end
end
