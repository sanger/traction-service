# frozen_string_literal: true

FactoryBot.define do
  factory :ont_instrument, class: 'Ont::Instrument' do
    name { 'GridIon' }
    max_number_of_flowcells { 5 }

    factory :ont_minion do
      name { 'MinIon' }
      max_number_of_flowcells { 1 }
    end

    factory :ont_promethion do
      name { 'PromethIon' }
      max_number_of_flowcells { 24 }
    end
  end
end
