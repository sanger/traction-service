class AddLoadingTargetToPacbioWells < ActiveRecord::Migration[6.0]
  def change
    add_column :pacbio_wells, :loading_target_p1_plus_p2, :decimal, precision: 3, scale: 2
  end
end
