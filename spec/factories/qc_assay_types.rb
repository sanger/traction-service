# frozen_string_literal: true

FactoryBot.define do
  factory :qc_assay_type do
    key { 'tissueMass' }
    label { 'Tissue Mass' }
    units { 'mg' }
  end
end
