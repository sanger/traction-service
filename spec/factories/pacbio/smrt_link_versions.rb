# frozen_string_literal: true

FactoryBot.define do
  factory :pacbio_smrt_link_version, class: 'Pacbio::SmrtLinkVersion' do
    sequence(:name) { |n| "v#{n}" }

    factory :pacbio_smrt_link_version_with_options do
      transient do
        option_count { 1 }
      end

      after(:create) do |smrt_link_version, evaluator|
        create_list(:pacbio_smrt_link_option_version, evaluator.option_count, smrt_link_version:)
      end
    end

    factory :pacbio_smrt_link_version_default, class: 'Pacbio::SmrtLinkVersion' do
      default { true }
      active { true }
    end
  end
end
