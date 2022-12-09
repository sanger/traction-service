# frozen_string_literal: true

FactoryBot.define do
  factory :ont_request, class: 'Ont::Request' do
    external_study_id
    cost_code

    association :library_type, :ont
    association :data_type, :ont

    after(:create) do |req|
      req.request = create(:request, requestable: req, sample: create(:sample))
    end
  end
end
