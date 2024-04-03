# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DualSourcedPool do
  describe '#source_identifier' do
    it 'returns a string of source tube barcodes' do
      tubes = create_list(:tube_with_pacbio_request, 2)
      used_aliquot_1 = create(:aliquot, source: tubes.first.pacbio_requests.first, aliquot_type: :derived)
      used_aliquot_2 = create(:aliquot, source: tubes.second.pacbio_requests.first, aliquot_type: :derived)
      pool = create(:pacbio_pool, used_aliquots: [used_aliquot_1, used_aliquot_2])

      expected = tubes.pluck(:barcode).join(',')
      expect(pool.source_identifier).to eq expected
    end

    it 'returns a string of source well positions from 1 plate' do
      plate = create(:plate_with_wells_and_requests, pipeline: 'pacbio')
      used_aliquot_1 = create(:aliquot, source: plate.wells.first.pacbio_requests.first, aliquot_type: :derived)
      used_aliquot_2 = create(:aliquot, source: plate.wells.last.pacbio_requests.first, aliquot_type: :derived)
      pool = create(:pacbio_pool, used_aliquots: [used_aliquot_1, used_aliquot_2])

      expected = "#{plate.barcode}:#{plate.wells.first.position}, #{plate.wells.last.position}"
      expect(pool.source_identifier).to eq expected
    end

    it 'returns a string of combined source well positions and source tube barcodes' do
      plate = create(:plate_with_wells_and_requests, pipeline: 'pacbio')
      tube = create(:tube_with_pacbio_request)
      used_aliquot_1 = create(:aliquot, source: plate.wells.first.pacbio_requests.first, aliquot_type: :derived)
      used_aliquot_2 = create(:aliquot, source: tube.pacbio_requests.first, aliquot_type: :derived)
      pool = create(:pacbio_pool, used_aliquots: [used_aliquot_1, used_aliquot_2])

      expected = "#{plate.barcode}:#{plate.wells.first.position},#{tube.barcode}"
      expect(pool.source_identifier).to eq expected
    end
  end
end
