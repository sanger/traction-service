# frozen_string_literal: true

FactoryBot.define do
  factory :qc_result do
    labware_barcode { 'AB1234' }
    sample_external_id { 'Samp-1234' }
    qc_assay_type
    value { '34' }
    qc_reception { nil }
  end
end
