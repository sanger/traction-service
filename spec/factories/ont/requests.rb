FactoryBot.define do
  factory :ont_request, class: Ont::Request do
    name { 'request name' }
    external_id { 'request external id' }

    factory :ont_request_with_tags do   
      transient do
        tags_count { 3 }
      end   

      after(:create) do |req, evaluator|
        create_list(:tag_taggable, evaluator.tags_count, taggable: req)
      end
    end
  end
end
