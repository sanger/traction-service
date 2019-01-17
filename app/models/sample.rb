# frozen_string_literal: true

# Sample
class Sample < ApplicationRecord
  attr_readonly :name
  before_create :set_state
  validates :name, :sequencescape_request_id, :species, presence: true
  validates :name, uniqueness: true

  def active?
    deactivated_at.nil?
  end

  private

  def set_state
    self.state = 'started'
  end
end
