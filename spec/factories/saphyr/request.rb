FactoryBot.define do
  factory :saphyr_request, class: Saphyr::Request do
    external_study_id { 1 }
    sample
  end
end