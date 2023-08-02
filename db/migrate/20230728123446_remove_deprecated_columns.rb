# Remove all of the deprecated columns from the PacbioWell and PacbioRun tables
class RemoveDeprecatedColumns < ActiveRecord::Migration[7.0]
  def change
    remove_column :pacbio_runs, :smrt_link_version_deprecated
    remove_column :pacbio_wells, :movie_time_deprecated
    remove_column :pacbio_wells, :on_plate_loading_concentration_deprecated
    remove_column :pacbio_wells, :pre_extension_time_deprecated
    remove_column :pacbio_wells, :generate_hifi_deprecated
    remove_column :pacbio_wells, :ccs_analysis_output_deprecated
    remove_column :pacbio_wells, :binding_kit_box_barcode_deprecated
    remove_column :pacbio_wells, :loading_target_p1_plus_p2_deprecated
  end
end
