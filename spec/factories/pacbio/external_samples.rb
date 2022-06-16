# frozen_string_literal: true

FactoryBot.define do
  factory :external_sample, class: 'Hash' do
    sequence(:name) { |n| "Sample#{n}" }
    external_id
    species { 'human' }
    library_type { 'library_type_1' }
    estimate_of_gb_required { 100 }
    number_of_smrt_cells { 3 }
    cost_code { 'PSD1234' }
    external_study_id

    initialize_with { attributes }

    skip_create
  end
end
