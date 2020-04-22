# frozen_string_literal: true

# Material
module Material
  extend ActiveSupport::Concern

  included do
    has_one :container_material, as: :material, dependent: :destroy
    delegate :receptacle, to: :container_material
  end
end
