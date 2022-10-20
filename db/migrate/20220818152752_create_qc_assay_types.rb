class CreateQcAssayTypes < ActiveRecord::Migration[7.0]
  def change
    create_table :qc_assay_types do |t|
      t.string :key, null: false
      t.string :label, null: false
      t.string :units

      t.timestamps
    end
  end
end
