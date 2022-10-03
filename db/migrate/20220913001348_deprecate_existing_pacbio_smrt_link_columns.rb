
# In this schema migration, we rename the SMRT Link option columns of Pacbio 
# wells by adding '_deprecated' suffix. We still need them because we will copy
# the values to the smrt_link_options JSON column (store) using the data 
# migration task in  lib/tasks/migrate_pacbio_well_smrt_link_options.rake .

class DeprecateExistingPacbioSmrtLinkColumns < ActiveRecord::Migration[7.0]
  def change
    rename_column :pacbio_wells, :on_plate_loading_concentration, :on_plate_loading_concentration_deprecated
    rename_column :pacbio_wells, :binding_kit_box_barcode, :binding_kit_box_barcode_deprecated
    rename_column :pacbio_wells, :pre_extension_time, :pre_extension_time_deprecated
    rename_column :pacbio_wells, :loading_target_p1_plus_p2, :loading_target_p1_plus_p2_deprecated
    rename_column :pacbio_wells, :movie_time, :movie_time_deprecated
  end
end
