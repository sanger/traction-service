# frozen_string_literal: true

FactoryBot.define do
  factory :pacbio_well_pool, class: 'Pacbio::WellPool' do
    well    { create(:pacbio_well) }
    pool    { create(:pacbio_pool) }
  end
end
