# frozen_string_literal: true

require 'rails_helper'

RSpec.describe V1::Shared::SourceIdentifierFilterable do
  # let(:dummy_class) do
  #   Class.new do
  #     include V1::Shared::SourceIdentifierFilterable

  #     def self.name
  #       'DummyClass'
  #     end
  #   end
  # end
  let(:dummy_class) do
    Class.new do
      include V1::Shared::SourceIdentifierFilterable

      def apply_source_identifier_filter(records, value, plate_join: :plate, tube_join: :tube, well_join: :well)
        self.class.apply_source_identifier_filter(records, value, plate_join: plate_join, tube_join: tube_join, well_join: well_join)
      end
    end
  end

  let(:dummy_instance) { dummy_class.new }

  describe '#apply_source_identifier_filter' do
    context 'when the source_identifier belongs to a plate' do
      it 'returns the correct records' do
        pacbio_plate = create(:plate_with_wells_and_requests, pipeline: 'pacbio')
        pacbio_plate_requests = pacbio_plate.wells.flat_map(&:pacbio_requests)
        records = Pacbio::Request.all

        filtered_records = dummy_instance.apply_source_identifier_filter(records, [pacbio_plate.barcode])

        expect(filtered_records.count).to eq(pacbio_plate_requests.count)
        expect(filtered_records.map(&:id)).to match_array(pacbio_plate_requests.map(&:id))
      end
    end

    context 'when the source_identifier belongs to a tube' do
      it 'returns the correct records' do
        pacbio_tube = create(:tube_with_pacbio_request)
        records = Pacbio::Request.all

        filtered_records = dummy_instance.apply_source_identifier_filter(records, [pacbio_tube.barcode])

        expect(filtered_records.count).to eq(pacbio_tube.pacbio_requests.count)
        expect(filtered_records.map(&:id)).to match_array(pacbio_tube.pacbio_requests.map(&:id))
      end
    end

    context 'when the source_identifier belongs to a plate and well separated by colon' do
      it 'returns the correct records' do
        pacbio_plate = create(:plate_with_wells_and_requests, pipeline: 'pacbio')
        pacbio_plate_requests = pacbio_plate.wells.first.pacbio_requests
        records = Pacbio::Request.all

        filtered_records = dummy_instance.apply_source_identifier_filter(records, ["#{pacbio_plate.barcode}:#{pacbio_plate.wells.first.position}"])

        expect(filtered_records.count).to eq(pacbio_plate_requests.count)
        expect(filtered_records.map(&:id)).to match_array(pacbio_plate_requests.map(&:id))
      end
    end

    context 'when the source_identifier contains multiple tubes, plates and invalid values' do
      it 'returns the correct records and logs warnings for invalid values' do
        pacbio_tube1 = create(:tube_with_pacbio_request)
        pacbio_tube2 = create(:tube_with_pacbio_request)
        pacbio_plate1 = create(:plate_with_wells_and_requests, pipeline: 'pacbio')
        pacbio_plate2 = create(:plate_with_wells_and_requests, pipeline: 'pacbio')
        pacbio_plate1_requests = pacbio_plate1.wells.first.pacbio_requests
        pacbio_plate2_requests = pacbio_plate2.wells.flat_map(&:pacbio_requests)

        source_identifiers = [
          pacbio_tube1.barcode,
          pacbio_tube2.barcode,
          "#{pacbio_plate1.barcode}:#{pacbio_plate1.wells.first.position}",
          pacbio_plate2.barcode,
          'INVALID_IDENTIFIER'
        ]

        records = Pacbio::Request.all

        filtered_records = dummy_instance.apply_source_identifier_filter(records, source_identifiers)

        total_requests = pacbio_tube1.pacbio_requests.length +
                         pacbio_tube2.pacbio_requests.length +
                         pacbio_plate1_requests.length +
                         pacbio_plate2_requests.length

        expect(filtered_records.count).to eq(total_requests)
        expect(filtered_records.map(&:id)).to match_array(
          pacbio_tube1.pacbio_requests.map(&:id) +
          pacbio_tube2.pacbio_requests.map(&:id) +
          pacbio_plate1_requests.map(&:id) +
          pacbio_plate2_requests.map(&:id)
        )
      end
    end

    context 'when the source_identifier contains malformed strings' do
      it 'when source_identifer contains malformed strings' do
        source_identifiers = [':test']
        records = Pacbio::Request.all
        filtered_records = dummy_instance.apply_source_identifier_filter(records, source_identifiers)

        expect(filtered_records.count).to eq(0)
      end
    end

    context 'when the source_identifer contains colon which includes plate barcode without well' do
      it 'returns the correct records for plate' do
        pacbio_plate1 = create(:plate_with_wells_and_requests, pipeline: 'pacbio')
        pacbio_plate_requests = pacbio_plate1.wells.flat_map(&:pacbio_requests)
        source_identifiers = ["#{pacbio_plate1.barcode}:"]
        records = Pacbio::Request.all
        filtered_records = dummy_instance.apply_source_identifier_filter(records, source_identifiers)
        expect(filtered_records.count).to eq(pacbio_plate_requests.count)
      end
    end

    context 'when the source_identifer contains colon followed by a valid well position' do
      it 'returns the correct records for plate' do
        pacbio_plate1 = create(:plate_with_wells_and_requests, pipeline: 'pacbio')
        create(:plate_with_wells_and_requests, pipeline: 'pacbio')

        source_identifiers = [
          ":#{pacbio_plate1.wells.first.position}"
        ]
        records = Pacbio::Request.all
        filtered_records = dummy_instance.apply_source_identifier_filter(records, source_identifiers)
        expect(filtered_records.count).to eq(2)
      end
    end

    context 'when using custom join conditions' do
      it 'returns the correct records for source_plate and source_tube' do
        pacbio_tube = create(:tube_with_pacbio_request)
        create(:pacbio_library, request: pacbio_tube.pacbio_requests[0])
        pacbio_plate = create(:plate_with_wells_and_requests, pipeline: 'pacbio')
        pacbio_plate.wells.first.pacbio_requests[0]
        create(:pacbio_library, request: pacbio_plate.wells.first.pacbio_requests[0])
        source_identifiers = [
          pacbio_tube.barcode,
          "#{pacbio_plate.barcode}:#{pacbio_plate.wells.first.position}"
        ]
        records = Pacbio::Library.all
        filtered_records = dummy_instance.apply_source_identifier_filter(records, source_identifiers, plate_join: :source_plate,
                                                                                                      tube_join: :source_tube,
                                                                                                      well_join: :source_well)

        expect(filtered_records.count).to eq(records.count)
        expect(filtered_records.map(&:id)).to match_array(records.map(&:id))
      end
    end
  end
end
