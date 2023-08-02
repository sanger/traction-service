# frozen_string_literal: true

FactoryBot.define do
  factory :ont_request, class: 'Ont::Request' do
    external_study_id
    cost_code

    library_type factory: %i[library_type ont]
    data_type factory: %i[data_type ont]

    after(:build) do |req|
      req.request = build(:request, requestable: req, sample: build(:sample))
    end
  end
end
