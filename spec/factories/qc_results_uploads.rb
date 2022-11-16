# frozen_string_literal: true

FactoryBot.define do
  factory :qc_results_upload, class: 'QcResultsUpload' do
    csv_data { 'MyText' }
    used_by { 'extraction' }
  end

  factory :qc_results_upload_factory do
    qc_results_upload
  end
end
