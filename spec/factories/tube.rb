FactoryBot.define do
  factory :tube do
    material { create(:saphyr_request) }
    sequence(:barcode) { |n| "TRAC-#{n}" }

    factory :tube_with_saphyr_library do
      material { create(:saphyr_library) }
    end
  end

end
