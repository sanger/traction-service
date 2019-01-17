class Sample < ApplicationRecord
  include Material

  attr_readonly :name
  before_create :set_state
  validates_presence_of :name, :sequencescape_request_id, :species
  validates_uniqueness_of :name
  has_many :libraries

  def active?
    deactivated_at.nil?
  end

  private

  def set_state
    self.state = 'started'
  end
end
