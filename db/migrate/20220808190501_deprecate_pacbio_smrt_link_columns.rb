class DeprecatePacbioSmrtLinkColumns < ActiveRecord::Migration[7.0]
  def change
    rename_column :pacbio_wells, :generate_hifi, :generate_hifi_deprecated
    rename_column :pacbio_wells, :ccs_analysis_output, :ccs_analysis_output_deprecated
  end
end
