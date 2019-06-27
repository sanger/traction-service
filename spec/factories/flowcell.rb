FactoryBot.define do
  factory :flowcell do
    association :chip, factory: :saphyr_chip

    position { 1 }

    factory :flowcell_with_library do
      library
    end
  end
end
