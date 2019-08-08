#TODO: abstact out behaviour for request factories for each pipeline
FactoryBot.define do
  factory :pacbio_request, class: Pacbio::Request do
    library_type { 'library_type_1' }
    estimate_of_gb_required { 100 }
    number_of_smrt_cells { 3 }
    cost_code { 'PSD1234' }
    external_study_id { '1' }

    after(:create) do |req|
      req.request = create(:request, requestable: req, sample: create(:sample))
    end
  end
end
