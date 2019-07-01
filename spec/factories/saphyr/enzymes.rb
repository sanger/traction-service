FactoryBot.define do
  factory :saphyr_enzyme, class: Saphyr::Enzyme do
    sequence(:name) { |n| "enZy.#{n}" }
  end
end
