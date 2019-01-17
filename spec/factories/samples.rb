# frozen_string_literal: true

FactoryBot.define do
  factory :sample do
    sequence(:name) { |n| "Sample#{n}" }
    state { 'started' }
    sequence(:sequencescape_request_id, &:to_s)
    species { 'human' }
    factory :sample_with_no_state do
      state { nil }
    end
  end
end
