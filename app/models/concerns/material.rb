# frozen_string_literal: true

# Material
module Material
  extend ActiveSupport::Concern

  included do
    belongs_to :container, polymorphic: true
    after_create :create_inverse_relationship
  end

  def create_inverse_relationship
    container.material = self
    container.save
  end
end
