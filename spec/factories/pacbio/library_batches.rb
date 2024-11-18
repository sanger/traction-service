# frozen_string_literal: true

FactoryBot.define do
  factory :pacbio_library_batch, class: 'Pacbio::LibraryBatch' do
    libraries { build_list(:pacbio_library, 1) }
  end
end
