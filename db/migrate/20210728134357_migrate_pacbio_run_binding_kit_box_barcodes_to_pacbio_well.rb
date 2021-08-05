class MigratePacbioRunBindingKitBoxBarcodesToPacbioWell < ActiveRecord::Migration[6.0]
  def up
    say 'adding binding_kit_box_barcode to pacbio wells'
    add_column :pacbio_wells, :binding_kit_box_barcode, :string

    say 'Populating all wells with their associated run binding kit box barcode'
    Pacbio::Run.all.each do |run|
      run.wells.each do |well|
        well.binding_kit_box_barcode = run.binding_kit_box_barcode
        well.save
      end
    end

    say 'removing binding_kit_box_barcode from pacbio runs'
    remove_column :pacbio_runs, :binding_kit_box_barcode
  end

  def down
    say 'adding binding_kit_box_barcode to pacbio runs'
    add_column :pacbio_runs, :binding_kit_box_barcode, :string

    say 'restoring original binding_kit_box_barcode values for pacbio runs'
    Pacbio::Run.all.each do |run|
      run.binding_kit_box_barcode = run.wells.first.binding_kit_box_barcode
      run.save
    end

    say 'removing binding_kit_box_barcode from pacbio wells'
    remove_column :pacbio_wells, :binding_kit_box_barcode
  end
end
