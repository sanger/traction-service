# frozen_string_literal: true

# Material
module Material
  extend ActiveSupport::Concern

  included do
    has_one :container, as: :receptacle, dependent: :destroy
    delegate :material, to: :container
  end
end
