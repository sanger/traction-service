# frozen_string_literal: true

FactoryBot.define do
  factory :sample do
    name { generate(:sample_name) }
    external_id
    species { 'human' }
  end
end
