# frozen_string_literal: true

FactoryBot.define do
  factory :qc_decision do
    status { :pass }
    decision_made_by { :long_read }
  end
end
