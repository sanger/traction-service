FactoryBot.define do
  factory :ont_request, class: Ont::Request do
    after(:create) do |req|
      req.request = create(:request, requestable: req, sample: create(:sample))
    end
  end
end
