# frozen_string_literal: true

FactoryBot.define do
  factory :library_type do
    sequence(:name) { |n| "Library Type #{n}" }
    pipeline { :pacbio }

    trait :ont do
      pipeline { :ont }
    end

    trait :pacbio do
      pipeline { :pacbio }
    end
  end
end
