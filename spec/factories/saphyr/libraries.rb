FactoryBot.define do
  factory :saphyr_library, class: Saphyr::Library do

    state { 'pending' }
    sample
    enzyme

    factory :library_no_state do
      state { nil }
    end
  end
end
