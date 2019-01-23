FactoryBot.define do
  factory :tube do
    sequence(:barcode) { |n| "TRAC-#{n}" }
  end
end
