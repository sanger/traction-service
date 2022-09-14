# frozen_string_literal: true

FactoryBot.define do
  factory :pacbio_smrt_link_option, class: 'Pacbio::SmrtLinkOption' do
    transient do
      sequence(:option) { |n| n }
    end

    key                 { "option_#{option}" }
    label               { "Option #{option}" }
    default_value       { 1 }
    validations         { { required: true, uniqueness: true } }

    factory :pacbio_smrt_link_option_with_versions do
      transient do
        version_count { 1 }
        version { create(:pacbio_smrt_link_version) }
      end

      after(:create) do |smrt_link_option, evaluator|
        create_list(:pacbio_smrt_link_option_version, evaluator.version_count, smrt_link_option:, smrt_link_version: evaluator.version)
      end
    end
  end
end
