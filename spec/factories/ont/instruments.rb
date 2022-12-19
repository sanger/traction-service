# frozen_string_literal: true

FactoryBot.define do
  factory :ont_instrument, class: 'Ont::Instrument' do
    name { 'G1' }
    instrument_type { 'GridIon' }
    max_number_of_flowcells { 5 }

    factory :ont_minion do
      name { 'M1' }
      instrument_type { 'MinIon' }
      max_number_of_flowcells { 1 }
    end

    factory :ont_promethion do
      name { 'P1' }
      instrument_type { 'PromethIon' }
      max_number_of_flowcells { 24 }
    end
  end
end
