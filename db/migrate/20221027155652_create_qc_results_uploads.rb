class CreateQcResultsUploads < ActiveRecord::Migration[7.0]
  def change
    create_table :qc_results_uploads do |t|
      t.text :csv_data

      t.timestamps
    end
  end
end
