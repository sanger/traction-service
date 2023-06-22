# frozen_string_literal: true

FactoryBot.define do
  factory :pacbio_run, class: 'Pacbio::Run' do
    sequence(:dna_control_complex_box_barcode) { |n| "Lxxxxx10171760012319#{n}" }
    comments { 'A Run Comment' }

    factory :pacbio_revio_run do
      system_name { 'Revio' }
      plates { [build(:pacbio_plate, wells: [build(:pacbio_well, row: 'A', column: '1')]), build(:pacbio_plate, wells: [build(:pacbio_well, row: 'A', column: '1')])] }
    end

    factory :pacbio_sequel_run do
      system_name { 'Sequel IIe' }
      plates { build_list(:pacbio_plate, 1, wells: [build(:pacbio_well)]) }
    end
  end
end
