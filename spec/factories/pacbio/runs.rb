# frozen_string_literal: true

FactoryBot.define do
  factory :pacbio_run, class: 'Pacbio::Run' do
    sequence(:sequencing_kit_box_barcode) { |n| "DM000110086180012312#{n}" }
    sequence(:dna_control_complex_box_barcode) { |n| "Lxxxxx10171760012319#{n}" }
    comments { 'A Run Comment' }
  end
end
