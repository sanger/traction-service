# frozen_string_literal: true

module AddUuid
  extend ActiveSupport::Concern

  included do
    before_create :add_uuid
  end

  def add_uuid
    self.uuid = SecureRandom.uuid
  end
end
