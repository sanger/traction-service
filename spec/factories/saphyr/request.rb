#TODO: abstact out behaviour for request factories for each pipeline
FactoryBot.define do
  factory :saphyr_request, class: Saphyr::Request do
    external_study_id { 1 }

    after(:create) do |req|
      req.request = create(:request, requestable: req, sample: create(:sample))
    end
  end
end