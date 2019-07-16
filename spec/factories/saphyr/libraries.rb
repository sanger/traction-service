FactoryBot.define do
  factory :saphyr_library, class: Saphyr::Library do

    state { 'pending' }
    request { create(:saphyr_request) }
    association :enzyme, factory: :saphyr_enzyme

    factory :library_no_state do
      state { nil }
    end
  end
end
