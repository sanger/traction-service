FactoryBot.define do
  factory :chip do
    run
    sequence(:barcode) { |n| "TRAC-#{n}" }
  end
end
