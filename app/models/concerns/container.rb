# frozen_string_literal: true

# Container
module Container
  extend ActiveSupport::Concern

  included do
    has_one :container_material, as: :container, dependent: :destroy
    delegate :material, to: :container_material, :allow_nil => true
  end
end
