# frozen_string_literal: true

FactoryBot.define do
  factory :data_type do
    sequence(:name) { |n| "Data Type #{n}" }
    pipeline { :pacbio }

    trait :ont do
      pipeline { :ont }
    end

    trait :pacbio do
      pipeline { :pacbio }
    end
  end
end
