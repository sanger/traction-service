FactoryBot.define do
  factory :library do
    state { 'pending' }
    sample

    factory :library_no_state do
      state { nil }
    end
  end
end
