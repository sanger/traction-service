# frozen_string_literal: true

# Material
module Material
  extend ActiveSupport::Concern

  included do
    has_one :container_material, as: :material, dependent: :destroy
    # We can't have a polymorphic has_one through relationship, so we just
    # delegate instead.
    delegate :container, to: :container_material, allow_nil: true
  end
end
