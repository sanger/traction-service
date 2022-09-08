# frozen_string_literal: true

FactoryBot.define do
  factory :pacbio_smrt_link_version, class: 'Pacbio::SmrtLinkVersion' do
    sequence(:name) { |n| "v#{n}" }
  end
end
