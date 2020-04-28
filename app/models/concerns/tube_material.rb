# frozen_string_literal: true

# Material
module TubeMaterial
  extend ActiveSupport::Concern
  include Material

  included do
    def tube
      return nil unless container.is_a?(Tube)

      container
    end
  end
end
