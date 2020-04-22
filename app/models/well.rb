# frozen_string_literal: true

# Well
class Well < ApplicationRecord
  include Receptacle

  belongs_to :plate

  validates :position, presence: true
end
