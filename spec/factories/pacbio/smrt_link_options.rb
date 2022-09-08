# frozen_string_literal: true

FactoryBot.define do
  factory :pacbio_smrt_link_option, class: 'Pacbio::SmrtLinkOption' do
    transient do
      sequence(:option) { |n| n }
      count { 1 }
    end

    key                 { "option_#{option}" }
    label               { "Option #{option}" }
    default_value       { 1 }
    validations         { { required: true, uniqueness: true } }
    data_type           { :string }

    after(:create) do |smrt_link_option, evaluator|
      create_list(:pacbio_smrt_link_option_version, evaluator.count, smrt_link_option:)
    end
  end
end
