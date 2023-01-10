# frozen_string_literal: true

FactoryBot.define do
  factory :qc_decision_result do
    qc_decision
    qc_result
  end
end
