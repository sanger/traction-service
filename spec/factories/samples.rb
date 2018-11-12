FactoryBot.define do
  factory :sample do
    sequence(:name) { |n| "Sample#{n}" }
  end
end
