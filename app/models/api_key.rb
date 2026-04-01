# frozen_string_literal: true

# Represents an API key that can be used to authenticate API requests.
class ApiKey < ApplicationRecord
  belongs_to :api_application

  enum :status, { active: 0, grace_period: 1, expired: 2 }

  validates :key_digest, presence: true, uniqueness: true
  validates :status, presence: true

  # Issues a new active key with a 6-month lifetime.
  # The plaintext key is a 256-bit random token returned once and never stored;
  # only its SHA-256 hex digest is persisted.
  # @param api_application [ApiApplication] the application to associate the new key with
  # @param expires_at [Time, nil] optional explicit expiry timestamp for the key (
  def self.issue!(api_application:, expires_at: 6.months.from_now)
    plaintext_key = SecureRandom.hex(32) # 64-char hex, 256 bits of entropy

    api_key = create!(
      api_application: api_application,
      key_digest: Digest::SHA256.hexdigest(plaintext_key),
      status: :active,
      expires_at: expires_at
    )

    { api_key: api_key, plaintext_key: plaintext_key }
  end
end
