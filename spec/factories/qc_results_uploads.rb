# frozen_string_literal: true

FactoryBot.define do
  factory :qc_results_upload, class: 'QcResultsUpload' do
    csv_data { 'MyText' }
  end
end