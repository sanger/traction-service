# frozen_string_literal: true

FactoryBot.define do
  factory :pacbio_well_library, class: 'Pacbio::WellLibrary' do
    well { association :pacbio_well }
    library { association :pacbio_library }
  end
end
