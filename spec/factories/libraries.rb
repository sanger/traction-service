FactoryBot.define do
  factory :library do
    state { 'pending' }
    sample

    factory :library_no_state do
      state { nil }
    end

    factory :library_with_tube do
      tube
    end
  end
end
