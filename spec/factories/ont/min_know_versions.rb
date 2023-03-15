# frozen_string_literal: true

FactoryBot.define do
  factory :ont_min_know_version, class: 'Ont::MinKnowVersion' do
    sequence(:name) { |n| "v#{n}" }

    factory :ont_min_know_version_default, class: 'Ont::MinKnowVersion' do
      default { true }
      active { true }
    end
  end
end
