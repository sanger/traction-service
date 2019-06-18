FactoryBot.define do
  factory :chip do
    run
    sequence(:barcode) { |n| "FLEVEAOLPTOWPNWU20319131581014320190911XXXXXXXXXXXXX-#{n}" }
  end
end
