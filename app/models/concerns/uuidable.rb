# frozen_string_literal: true

# Adds a uuid to model
module Uuidable
  extend ActiveSupport::Concern

  included do
    before_create :add_uuid
  end

  def add_uuid
    self.uuid = SecureRandom.uuid
  end
end
