FactoryBot.define do
  factory :tube do
    material { create(:sample) }
    sequence(:barcode) { |n| "TRAC-#{n}" }

    factory :tube_with_library do
      material { create(:library) }
    end
  end

end
