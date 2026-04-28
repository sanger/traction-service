# frozen_string_literal: true

FactoryBot.define do
  factory :api_key do
    api_application
    key_digest { Digest::SHA256.hexdigest(SecureRandom.hex(32)) }
    status { :active }
    expires_at { 1.year.from_now }
  end
end
