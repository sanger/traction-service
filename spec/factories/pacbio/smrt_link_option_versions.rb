# frozen_string_literal: true

FactoryBot.define do
  factory :pacbio_smrt_link_option_version, class: 'Pacbio::SmrtLinkOptionVersion' do
    smrt_link_option { association :pacbio_smrt_link_option }
    smrt_link_version { association :pacbio_smrt_link_version }
  end
end
