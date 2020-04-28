# frozen_string_literal: true

# Material
module TubeMaterial
  extend ActiveSupport::Concern
  include Material

  included do
    def tube
      return nil unless self.container.is_a?(Tube)

      self.container
    end
  end
end
