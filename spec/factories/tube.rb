FactoryBot.define do
  factory :tube do
    material { create(:sample) }
    sequence(:barcode) { |n| "TRAC-#{n}" }

    factory :tube_with_saphyr_library do
      material { create(:saphyr_library) }
    end
  end

end
