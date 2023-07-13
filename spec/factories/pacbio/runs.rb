# frozen_string_literal: true

# @param [Array] positions
# @return [Array]
# builds wells by position
def build_wells_by_position(positions)
  positions.map do |position|
    row, column = position.chars
    build(:pacbio_well, row:, column:)
  end
end

# we could do a bit more work here to make this more flexible
# to cope with different types of runs
FactoryBot.define do
  factory :pacbio_run, class: 'Pacbio::Run' do
    sequence(:dna_control_complex_box_barcode) { |n| "Lxxxxx10171760012319#{n}" }
    comments { 'A Run Comment' }

    factory :pacbio_revio_run do
      transient do
        well_positions_plate_1 { ['A1'] }
        well_positions_plate_2 { ['A1'] }
      end

      system_name { 'Revio' }
      plates do
        [
          build(:pacbio_plate, plate_number: 1, wells: build_wells_by_position(well_positions_plate_1)),
          build(:pacbio_plate, plate_number: 2, wells: build_wells_by_position(well_positions_plate_2))
        ]
      end
    end

    factory :pacbio_sequel_run do
      system_name { 'Sequel IIe' }
      plates { build_list(:pacbio_plate, 1, plate_number: 1, wells: [build(:pacbio_well)]) }
    end
  end
end
