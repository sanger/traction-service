FactoryBot.define do
  factory :tube do
    sequence(:barcode) { |n| "TRAC-#{n}" }

    trait :with_sample_material do
      association(:material, factory: :sample)
    end

    trait :with_library_material do
      association(:material, factory: :library)
    end
  end
end
