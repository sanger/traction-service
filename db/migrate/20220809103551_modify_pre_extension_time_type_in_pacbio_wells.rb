class ModifyPreExtensionTimeTypeInPacbioWells < ActiveRecord::Migration[7.0]
  def change
    change_column :pacbio_wells, :pre_extension_time, :decimal, precision: 3, scale: 1
  end
end
