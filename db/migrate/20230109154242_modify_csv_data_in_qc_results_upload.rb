class ModifyCsvDataInQcResultsUpload < ActiveRecord::Migration[7.0]
  def change
    change_column :qc_results_uploads, :csv_data, :longtext
  end
end
