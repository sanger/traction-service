# frozen_string_literal: true

# Container
module Container
  extend ActiveSupport::Concern

  included do
    has_many :container_materials, as: :container, dependent: :destroy

    def materials
      return container_materials.map { |container_material| container_material.material }
    end
  end
end
