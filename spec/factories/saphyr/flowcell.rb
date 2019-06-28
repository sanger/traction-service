FactoryBot.define do
  factory :saphyr_flowcell, class: Saphyr::Flowcell do

    association :chip, factory: :saphyr_chip

    position { 1 }

    factory :flowcell_with_library do
      library
    end
  end
end
