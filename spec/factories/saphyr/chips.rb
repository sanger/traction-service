FactoryBot.define do
  factory :saphyr_chip, class: Saphyr::Chip do
    run { create(:saphyr_run) }

    sequence(:barcode) { |n| "FLEVEAOLPTOWPNWU20319131581014320190911XXXXXXXXXXXXX-#{n}" }

    factory :saphyr_chip_with_flowcells do
      flowcells { create_list(:saphyr_flowcell, 2) }
    end
  end
end
