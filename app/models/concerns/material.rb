# frozen_string_literal: true

# Material
module Material
  extend ActiveSupport::Concern

  included do
    has_one :container, as: :material, dependent: :destroy
    delegate :receptacle, to: :container
  end
end
