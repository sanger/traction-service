FactoryBot.define do
  factory :tube do
    sequence(:barcode) { |n| "TRAC-#{n}" }

    factory :tube_with_library do
      library
    end
  end
end
