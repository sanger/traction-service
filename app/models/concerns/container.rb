# frozen_string_literal: true

# Container
module Container
  extend ActiveSupport::Concern

  included do
    has_one :material, polymorphic: true, dependent: :nullify
  end
end
