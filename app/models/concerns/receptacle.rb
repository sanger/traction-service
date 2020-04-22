# frozen_string_literal: true

# Receptacle
module Receptacle
  extend ActiveSupport::Concern

  included do
    has_one :container_material, as: :receptacle, dependent: :destroy
    delegate :material, to: :container_material
  end
end
