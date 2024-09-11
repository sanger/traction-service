# frozen_string_literal: true

FactoryBot.define do
  factory :workflow_step do
    sequence(:code) { |n| "Code#{n}" }
    sequence(:stage) { |n| "Stage#{n}" }
    workflow
  end
end
