# frozen_string_literal: true

FactoryBot.define do
  factory :printer do
    name { |n| "Printer#{('A'.ord + n).chr}" }
    labware_type { 1 }
    active { true }
  end
end
