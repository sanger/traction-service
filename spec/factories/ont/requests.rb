FactoryBot.define do
  factory :ont_request, class: Ont::Request do
    external_study_id { '1' }
    after(:create) do |req|
      req.request = create(:request, requestable: req, sample: create(:sample))
    end

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
