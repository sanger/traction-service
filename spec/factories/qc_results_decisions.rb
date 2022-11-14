FactoryBot.define do
  factory :qc_results_decision do
    # qc_result { create :qc_result }
    # qc_decision { create :qc_decision }
    qc_result
    qc_decision
  end
end
