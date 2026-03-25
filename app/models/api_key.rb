# frozen_string_literal: true

# Represents an API key that can be used to authenticate API requests.
class ApiKey < ApplicationRecord
  belongs_to :api_application

  enum :status, { active: 0, grace_period: 1, expired: 2, revoked: 3 }

  validates :key, presence: true, uniqueness: true
  validates :status, presence: true
  validates :expires_at, presence: true
end
