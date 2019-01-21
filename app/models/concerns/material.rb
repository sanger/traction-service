# frozen_string_literal: true

# Material
module Material
  extend ActiveSupport::Concern

  included do
    has_one :tube, as: :material
  end
end
