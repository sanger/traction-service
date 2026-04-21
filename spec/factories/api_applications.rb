# frozen_string_literal: true

FactoryBot.define do
  factory :api_application do
    sequence(:name) { |n| "api-app-#{n}" }
    sequence(:contact_name) { |n| "Developer #{n}" }
    sequence(:contact_email) { |n| "developer#{n}@example.com" }
    description { 'Programmatic integration client' }
  end
end
