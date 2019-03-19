# frozen_string_literal: true

FactoryBot.define do
  factory :sample do
    sequence(:name) { |n| "Sample#{n}" }
    sequence(:external_id, &:to_s)
    species { 'human' }
  end
end
