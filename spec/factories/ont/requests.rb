# frozen_string_literal: true

FactoryBot.define do
  factory :ont_request, class: 'Ont::Request' do
    external_study_id
    cost_code

    library_type factory: %i[library_type ont]
    data_type factory: %i[data_type ont]

    after(:create) do |req|
      req.request = create(:request, requestable: req, sample: create(:sample))
    end
  end
end
