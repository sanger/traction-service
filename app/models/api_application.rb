# frozen_string_literal: true

# Represents an application that can access the API using API keys.
class ApiApplication < ApplicationRecord
  has_many :api_keys, dependent: :destroy

  validates :name, presence: true
  validates :contact_email, presence: true

  # Rotates keys following the lifecycle:
  #   grace_period -> expired  (no longer valid)
  #   active       -> grace_period  (still valid, but caller is warned)
  #   new key      -> active
  # @param expires_at [Time, nil] the optional expiration time for the new key
  # @return [Hash] a hash containing the new API key and its plaintext representation
  def rotate_api_key!(expires_at: nil)
    transaction do
      now = Time.current
      api_keys.grace_period.find_each { |key| key.update!(status: :expired, updated_at: now) }
      api_keys.active.find_each { |key| key.update!(status: :grace_period, updated_at: now) }
      issue_api_key!(expires_at: expires_at)
    end
  end

  private

  # Issues a new API key for this application.
  #
  # @param expires_at [Time, nil] Optional explicit expiry timestamp for the key.
  # @return [Hash] Result from {ApiKey.issue!} containing :api_key and :plaintext_key.
  def issue_api_key!(expires_at: nil)
    ApiKey.issue!(api_application: self, expires_at: expires_at)
  end
end
