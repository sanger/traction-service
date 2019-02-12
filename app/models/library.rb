# frozen_string_literal: true

# Library
class Library < ApplicationRecord
  include Material

  before_create :set_state
  belongs_to :sample
  belongs_to :enzyme
  belongs_to :flowcell, optional: true

  scope :active, -> { where(deactivated_at: nil) }

  def active?
    deactivated_at.nil?
  end

  def set_state
    self.state = 'pending'
  end

  def deactivate
    return true unless active?

    update(deactivated_at: DateTime.current)
  end
end
