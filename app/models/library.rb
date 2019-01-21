class Library < ApplicationRecord
  include Material

  before_create :set_state
  belongs_to :sample

  def set_state
    self.state = 'pending'
  end
end
