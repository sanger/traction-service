# frozen_string_literal: true

FactoryBot.define do
  sequence(:uuid, aliases: [:external_study_id]) { SecureRandom.uuid }
  sequence(:cost_code, 10000) { |n| "S#{n}" }
  sequence(:sample_name) { |n| "Sample#{n}" }
  sequence(:barcode) { |n| "NT#{n}" }
end
