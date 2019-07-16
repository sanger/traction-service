# frozen_string_literal: true

# request
class Request < ApplicationRecord
  belongs_to :sample
  belongs_to :requestable, polymorphic: true

  validates_associated :sample, :requestable
end
