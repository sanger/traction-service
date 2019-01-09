class Sample < ApplicationRecord
  attr_readonly :name
  before_create :set_state
  validates_presence_of :name, :sequencescape_request_id
  validates_uniqueness_of :name

  def active?
    deactivated_at.nil?
  end

  private

  def set_state
    self.state = 'started'
  end
end
