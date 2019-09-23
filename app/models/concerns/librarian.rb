# frozen_string_literal: true

# Material
module Librarian
  extend ActiveSupport::Concern

  included do 
    before_create :set_state

    scope :active, -> { where(deactivated_at: nil) }
  end

  def active?
    deactivated_at.nil?
  end

  def set_state
    self.state = 'pending'
  end

  def deactivate
    return false unless active?

    update(deactivated_at: DateTime.current)
  end
end
