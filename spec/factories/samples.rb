FactoryBot.define do
  factory :sample do
    sequence(:name) { |n| "Sample#{n}" }
    state { "started" }
  end
end
