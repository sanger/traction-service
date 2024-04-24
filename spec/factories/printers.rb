# frozen_string_literal: true

FactoryBot.define do
  factory :printer do
    sequence(:name) { |n| "Printer#{('A'.ord + n).chr}" }
    labware_type { Printer.labware_types.keys.sample }
    active { true }
  end
end
