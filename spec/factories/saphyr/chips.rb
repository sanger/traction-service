# frozen_string_literal: true

FactoryBot.define do
  factory :saphyr_chip, class: 'Saphyr::Chip' do
    run { association :saphyr_run }

    sequence(:barcode) { |n| "FLEVEAOLPTOWPNWU20319131581014320190911XXXXXXXXXXXXX-#{n}" }

    factory :saphyr_chip_with_flowcells do
      flowcells { create_list(:saphyr_flowcell, 2) }
    end

    factory :saphyr_chip_with_flowcells_and_library_in_tube do
      flowcells { create_list(:saphyr_flowcell_with_library_in_tube, 2) }
    end
  end
end
