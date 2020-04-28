# frozen_string_literal: true

# Container
module Container
  extend ActiveSupport::Concern

  included do
    has_many :container_materials, as: :container, dependent: :destroy

    def materials
      container_materials.map(&:material)
    end
  end
end
