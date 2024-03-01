# frozen_string_literal: true

FactoryBot.define do
  factory :pacbio_request, class: 'Pacbio::Request' do
    library_type { 'library_type_1' }
    estimate_of_gb_required { '100' }
    number_of_smrt_cells { 3 }
    cost_code
    external_study_id

    after(:build) do |req|
      req.request = build(:request, requestable: req, sample: build(:sample))
    end
  end
end
