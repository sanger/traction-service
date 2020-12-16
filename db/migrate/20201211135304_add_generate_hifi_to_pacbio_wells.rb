class AddGenerateHifiToPacbioWells < ActiveRecord::Migration[6.0]
  def change
    add_column :pacbio_wells, :generate_hifi, :integer
    add_column :pacbio_wells, :ccs_analysis_output, :string
  end
end
