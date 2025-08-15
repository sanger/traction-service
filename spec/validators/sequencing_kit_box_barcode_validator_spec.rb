# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SequencingKitBoxBarcodeValidator do
  before do
    create(:pacbio_smrt_link_version, name: 'v12_revio', default: true)
  end

  it 'is valid when all there are no existing plates with the same sequencing_kit_box_barcode' do
    create(:pacbio_generic_run, system_name: 'Revio', plates: [build(:pacbio_plate, plate_number: 1, sequencing_kit_box_barcode: '5678', wells: [build(:pacbio_well, row: 'A', column: '1')])])
    new_pacbio_run = create(:pacbio_generic_run, system_name: 'Revio', plates: [build(:pacbio_plate, plate_number: 1, sequencing_kit_box_barcode: '1234', wells: [build(:pacbio_well, row: 'A', column: '1')])])
    expect(new_pacbio_run.plates.first).to be_valid
  end

  it 'is invalid when all there are 2 existing plates with the same sequencing_kit_box_barcode' do
    create(:pacbio_generic_run, system_name: 'Revio', plates: [build(:pacbio_plate, plate_number: 1, sequencing_kit_box_barcode: '1234', wells: [build(:pacbio_well, row: 'A', column: '1')])])
    create(:pacbio_generic_run, system_name: 'Revio', plates: [build(:pacbio_plate, plate_number: 1, sequencing_kit_box_barcode: '1234', wells: [build(:pacbio_well, row: 'B', column: '1')])])

    new_pacbio_run = build(:pacbio_generic_run, system_name: 'Revio', plates: [build(:pacbio_plate, plate_number: 1, sequencing_kit_box_barcode: '1234', wells: [build(:pacbio_well, row: 'A', column: '1')])])
    expect(new_pacbio_run).not_to be_valid
    expect(new_pacbio_run.errors.full_messages).to include('Plates plate 1 plates sequencing kit box barcode has already been used on 2 plates')
  end

  it 'is invalid when the plate re-uses a sequencing_kit_box_barcde with clashing wells' do
    create(:pacbio_generic_run, system_name: 'Revio', plates: [build(:pacbio_plate, plate_number: 1, sequencing_kit_box_barcode: '1234', wells: [build(:pacbio_well, row: 'A', column: '1')])])

    new_pacbio_run = build(:pacbio_generic_run, system_name: 'Revio', plates: [build(:pacbio_plate, plate_number: 1, sequencing_kit_box_barcode: '1234', wells: [build(:pacbio_well, row: 'A', column: '1')])])
    expect(new_pacbio_run).not_to be_valid
    expect(new_pacbio_run.errors.full_messages).to include('Plates plate 1 plates A1 have already been used for plate 1234')
  end

  it 'does not include wells that are marked for destruction' do
    well = build(:pacbio_well, row: 'A', column: '1')
    create(:pacbio_generic_run, system_name: 'Revio', plates: [build(:pacbio_plate, plate_number: 1, sequencing_kit_box_barcode: '5678', wells: [well])])
    well.reload.mark_for_destruction
    new_pacbio_run = create(:pacbio_generic_run, system_name: 'Revio', plates: [build(:pacbio_plate, plate_number: 1, sequencing_kit_box_barcode: '1234', wells: [build(:pacbio_well, row: 'A', column: '1')])])
    expect(new_pacbio_run.plates.first).to be_valid
  end

  it 'does not validate plates that are from Sequel IIe' do
    create(:pacbio_generic_run, system_name: 'Sequel IIe', plates: [build(:pacbio_plate, plate_number: 1, sequencing_kit_box_barcode: '1234', wells: [build(:pacbio_well, row: 'A', column: '1')])])
    new_pacbio_run = create(:pacbio_generic_run, system_name: 'Sequel IIe', plates: [build(:pacbio_plate, plate_number: 1, sequencing_kit_box_barcode: '1234', wells: [build(:pacbio_well, row: 'A', column: '1')])])
    expect(new_pacbio_run.plates.first).to be_valid
  end

  it 'returns no errors when plates in the same run have the same sequencing_kit_box_barcode' do
    run = create(:pacbio_generic_run, system_name: 'Revio', plates: [
      build(:pacbio_plate, plate_number: 1, sequencing_kit_box_barcode: '1234', wells: [build(:pacbio_well, row: 'A', column: '1')]),
      build(:pacbio_plate, plate_number: 2, sequencing_kit_box_barcode: '1234', wells: [build(:pacbio_well, row: 'A', column: '1')])
    ])
    run.plates.first.update(sequencing_kit_box_barcode: '1234')
    run.plates.second.update(sequencing_kit_box_barcode: '1234')
    run.save

    expect(run.errors).to be_empty
  end
end
