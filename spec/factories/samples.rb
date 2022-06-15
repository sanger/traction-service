# frozen_string_literal: true

FactoryBot.define do
  factory :sample do
    name { generate(:sample_name) }
    sequence(:external_id, &:to_s)
    species { 'human' }
  end
end
