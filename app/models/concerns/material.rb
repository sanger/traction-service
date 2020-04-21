# frozen_string_literal: true

# Material
module Material extend ActiveSupport::Concern

  included do
    belongs_to :container, polymorphic: true
  end
end
