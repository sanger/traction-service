# frozen_string_literal: true

FactoryBot.define do
  factory :ont_instrument, class: 'Ont::Instrument' do
    name { 'GridION-1' }
    max_number_of_flowcells { 5 }

    factory :ont_minion do
      name { 'MinION-1' }
      max_number_of_flowcells { 1 }
    end

    factory :ont_promethion do
      name { 'PromethION-1' }
      max_number_of_flowcells { 24 }
    end
  end
end
