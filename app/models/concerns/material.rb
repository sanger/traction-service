# frozen_string_literal: true

# Material
module Material
  extend ActiveSupport::Concern

  included do
    has_one :container_material, as: :material, dependent: :destroy
    delegate :container, to: :container_material, allow_nil: true
  end
end
