# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Plate do
  context 'labware' do
    let(:labware_model) { :plate }

    it_behaves_like 'labware'
  end

  it 'returns wells by column then row' do
    plate = create(:plate_with_wells, row_count: 3, column_count: 12)
    expected_positions = %w[
      A1 B1 C1 A2 B2 C2 A3 B3 C3 A4 B4 C4
      A5 B5 C5 A6 B6 C6 A7 B7 C7 A8 B8 C8
      A9 B9 C9 A10 B10 C10 A11 B11 C11 A12 B12 C12
    ]
    sorted_positions = plate.wells_by_column_then_row.map(&:position)
    expect(sorted_positions).to eq(expected_positions)
  end

  it 'returns wells by row then column' do
    plate = create(:plate_with_wells, row_count: 3, column_count: 12)
    expected_positions = %w[
      A1 A2 A3 A4 A5 A6 A7 A8 A9 A10 A11 A12
      B1 B2 B3 B4 B5 B6 B7 B8 B9 B10 B11 B12
      C1 C2 C3 C4 C5 C6 C7 C8 C9 C10 C11 C12
    ]
    sorted_positions = plate.wells_by_row_then_column.map(&:position)
    expect(sorted_positions).to eq(expected_positions)
  end

  context 'by pipeline' do
    it 'returns the correct plates' do
      create_list(:plate_with_wells_and_requests, 5, pipeline: 'pacbio')
      expect(described_class.by_pipeline(:pacbio).length).to eq(5)
    end
  end

  context 'by barcode' do
    let!(:plates) { create_list(:plate, 5) }

    it 'returns the correct plates' do
      barcodes = plates.pluck(:barcode)[0..1]
      expect(described_class.by_barcode(barcodes).length).to eq(2)
    end
  end
end
