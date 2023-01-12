# frozen_string_literal: true

FactoryBot.define do
  factory :ont_instrument, class: 'Ont::Instrument' do
    sequence(:name) { |n| "O#{n}" }
    instrument_type { 'GridION' }
    max_number_of_flowcells { 5 }

    factory :ont_gridion do
      sequence(:name) { |n| "G#{n}" }
    end

    factory :ont_minion do
      sequence(:name) { |n| "M#{n}" }
      instrument_type { 'MinION' }
      max_number_of_flowcells { 1 }
    end

    factory :ont_promethion do
      sequence(:name) { |n| "P#{n}" }
      instrument_type { 'PromethION' }
      max_number_of_flowcells { 24 }
    end
  end
end
