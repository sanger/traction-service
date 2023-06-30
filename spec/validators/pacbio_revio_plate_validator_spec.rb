# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PacbioRevioPlateValidator do
  let!(:version12) { create(:pacbio_smrt_link_version, name: 'v12_revio', default: true) }

  it 'is valid when all there are no existing plates with the same sequencing_kit_box_barcode' do
    create(:pacbio_run, system_name: 'Revio', plates: [build(:pacbio_plate, plate_number: 1, sequencing_kit_box_barcode: '5678', wells: [build(:pacbio_well, row: 'A', column: '1')])])
    new_pacbio_run = create(:pacbio_run, system_name: 'Revio', plates: [build(:pacbio_plate, plate_number: 1, sequencing_kit_box_barcode: '1234', wells: [build(:pacbio_well, row: 'A', column: '1')])])
    expect(new_pacbio_run.plates.first).to be_valid
  end

  it 'is invalid when all there are 2 existing plates with the same sequencing_kit_box_barcode' do
    create(:pacbio_run, system_name: 'Revio', plates: [build(:pacbio_plate, plate_number: 1, sequencing_kit_box_barcode: '1234', wells: [build(:pacbio_well, row: 'A', column: '1')])])
    create(:pacbio_run, system_name: 'Revio', plates: [build(:pacbio_plate, plate_number: 1, sequencing_kit_box_barcode: '1234', wells: [build(:pacbio_well, row: 'B', column: '1')])])

    new_pacbio_run = build(:pacbio_run, system_name: 'Revio', plates: [build(:pacbio_plate, plate_number: 1, sequencing_kit_box_barcode: '1234', wells: [build(:pacbio_well, row: 'A', column: '1')])])
    expect(new_pacbio_run.plates.first).not_to be_valid
    expect(new_pacbio_run.plates.first.errors.full_messages).to include('Sequencing kit box barcode has already been used on 2 plates')
  end

  it 'is invalid when the plate re-uses a sequencing_kit_box_barcde with clashing wells' do
    create(:pacbio_run, system_name: 'Revio', plates: [build(:pacbio_plate, plate_number: 1, sequencing_kit_box_barcode: '1234', wells: [build(:pacbio_well, row: 'A', column: '1')])])

    new_pacbio_run = build(:pacbio_run, system_name: 'Revio', plates: [build(:pacbio_plate, plate_number: 1, sequencing_kit_box_barcode: '1234', wells: [build(:pacbio_well, row: 'A', column: '1')])])
    expect(new_pacbio_run.plates.first).not_to be_valid
    expect(new_pacbio_run.plates.first.errors.full_messages).to include('Wells A1 have already been used for sequencing kit box barcode 1234')
  end

  it 'will not validate plates that are from Sequel IIe ' do
    create(:pacbio_run, system_name: 'Sequel IIe', plates: [build(:pacbio_plate, plate_number: 1, sequencing_kit_box_barcode: '1234', wells: [build(:pacbio_well, row: 'A', column: '1')])])
    new_pacbio_run = create(:pacbio_run, system_name: 'Sequel IIe', plates: [build(:pacbio_plate, plate_number: 1, sequencing_kit_box_barcode: '1234', wells: [build(:pacbio_well, row: 'A', column: '1')])])
    expect(new_pacbio_run.plates.first).to be_valid
  end
end
