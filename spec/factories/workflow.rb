# frozen_string_literal: true

FactoryBot.define do
  factory :workflow do
    sequence(:name) { |n| "Workflow #{n}" }
    pipeline { :pacbio }

    trait :ont do
      pipeline { :ont }
    end

    trait :pacbio do
      pipeline { :pacbio }
    end
  end
end
