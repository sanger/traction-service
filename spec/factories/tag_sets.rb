FactoryBot.define do
  factory :tag_set do
    sequence(:name) { |n| "Tag-Set-#{n}" }
    sequence(:uuid) { |n| n }
  end
end
