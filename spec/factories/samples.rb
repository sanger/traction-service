# frozen_string_literal: true

FactoryBot.define do
  factory :sample do
    name { generate(:sample_name) }
    external_id
    species { 'human' }
    public_name { 'PublicName' }
    priority_level { 'Medium' }
    country_of_origin { 'United Kingdom' }
  end
end
