# frozen_string_literal: true

FactoryBot.define do
  factory :pacbio_request, class: 'Pacbio::Request' do
    library_type { 'library_type_1' }
    estimate_of_gb_required { '100' }
    number_of_smrt_cells { 3 }
    cost_code
    external_study_id

    transient do
      sample { build(:sample) }
    end

    after(:build) do |req, evaluator|
      req.request = build(:request, requestable: req, sample: evaluator.sample)
    end

    factory :pacbio_request_with_tube do
      transient do
        tube { build(:tube) }
      end

      after(:build) do |req, evaluator|
        req.tube = evaluator.tube
      end
    end
  end
end
