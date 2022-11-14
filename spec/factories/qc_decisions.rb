FactoryBot.define do
  factory :qc_decision do
    barcode { "SQ-XYZ-L" }
    status { :pass }
    decision_made_by { :long_read }
  end
end
