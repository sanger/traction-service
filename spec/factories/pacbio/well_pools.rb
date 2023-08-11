# frozen_string_literal: true

FactoryBot.define do
  factory :pacbio_well_pool, class: 'Pacbio::WellPool' do
    well { association :pacbio_well }
    pool { association :pacbio_pool }
  end
end
