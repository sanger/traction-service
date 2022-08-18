class CreateQcAssayTypes < ActiveRecord::Migration[7.0]
  def change
    create_table :qc_assay_types do |t|
      t.string :key
      t.string :label
      t.string :units

      t.timestamps
    end
  end
end
