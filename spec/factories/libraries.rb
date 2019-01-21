FactoryBot.define do
  factory :library do
    state { 'pending' }
    sample

    factory :library_no_state do
      state { nil }
    end

    factory :library_with_tube do
      association :tube, :with_library_material
    end
  end
end
