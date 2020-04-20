# frozen_string_literal: true

# Material
module TubeMaterial
  extend ActiveSupport::Concern

  included do
    has_one :tube, as: :material, dependent: :nullify
  end
end
