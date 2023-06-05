# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DualSourcedPool do
  describe '#source_identifier' do
    it 'returns a string of source tube barcodes' do
      tubes = create_list(:tube_with_pacbio_request, 2)
      lib1 = create(:pacbio_library, request: tubes.first.pacbio_requests.first)
      lib2 = create(:pacbio_library, request: tubes.second.pacbio_requests.first)
      pool = create(:pacbio_pool, libraries: [lib1, lib2])

      expected = tubes.pluck(:barcode).join(',')
      expect(pool.source_identifier).to eq expected
    end

    it 'returns a string of source well positions from 1 plate' do
      plate = create(:plate_with_wells_and_requests, pipeline: 'pacbio')
      lib1 = create(:pacbio_library, request: plate.wells.first.pacbio_requests.first)
      lib2 = create(:pacbio_library, request: plate.wells.last.pacbio_requests.first)
      pool = create(:pacbio_pool, libraries: [lib1, lib2])

      expected = "#{plate.barcode}:#{plate.wells.first.position}, #{plate.wells.last.position}"
      expect(pool.source_identifier).to eq expected
    end

    it 'returns a string of combined source well positions and source tube barcodes' do
      plate = create(:plate_with_wells_and_requests, pipeline: 'pacbio')
      tube = create(:tube_with_pacbio_request)
      lib1 = create(:pacbio_library, request: plate.wells.first.pacbio_requests.first)
      lib2 = create(:pacbio_library, request: tube.pacbio_requests.first)
      pool = create(:pacbio_pool, libraries: [lib1, lib2])

      expected = "#{plate.barcode}:#{plate.wells.first.position},#{tube.barcode}"
      expect(pool.source_identifier).to eq expected
    end
  end
end
