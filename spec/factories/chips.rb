FactoryBot.define do
  factory :chip do
    run
    sequence(:barcode) { |n| "FLEVEAOLPTOWPNWU20319131581014320190911XXXXXXXXXXXXX-#{n}" }

    factory :chip_with_flowcells do
      flowcells { create_list(:flowcell, 2) }
    end
  end
end
