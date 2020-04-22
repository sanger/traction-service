# frozen_string_literal: true

# Well
class Well < ApplicationRecord
  include Material

  belongs_to :plate

  validates :position, presence: true
end
