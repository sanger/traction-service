FactoryBot.define do
  factory :sample do
    sequence(:name) { |n| "Sample#{n}" }
    state { "started" }

    factory :sample_with_no_state do
      state { nil }
    end

  end

end
