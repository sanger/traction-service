# frozen_string_literal: true

# Represents an application that can access the API using API keys.
class ApiApplication < ApplicationRecord
  has_many :api_keys, dependent: :destroy

  enum :privilege, { full: 0, read_only: 1 }

  validates :name, presence: true
  validates :contact_email, presence: true
end
