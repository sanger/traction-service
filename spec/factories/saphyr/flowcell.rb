FactoryBot.define do
  factory :saphyr_flowcell, class: Saphyr::Flowcell do
    association :chip, factory: :saphyr_chip

    position { 1 }

    factory :saphyr_flowcell_with_library do
      library { create(:saphyr_library) }
    end

    factory :saphyr_flowcell_with_library_in_tube do
      library { create(:saphyr_library_in_tube) }
    end
  end
end
