# frozen_string_literal: true

# Container
module Container
  extend ActiveSupport::Concern

  included do
    belongs_to :material, polymorphic: true
  end
end
