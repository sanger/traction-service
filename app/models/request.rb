# frozen_string_literal: true

# Request
class Request < ApplicationRecord
  belongs_to :sample
  belongs_to :requestable, polymorphic: true

  validates_associated :sample, :requestable
end
