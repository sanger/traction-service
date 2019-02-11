FactoryBot.define do
  factory :enzyme do
    sequence(:name) { |n| "enZy.#{n}" }
  end
end
