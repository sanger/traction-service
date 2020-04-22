# frozen_string_literal: true

# Well
class Well < ApplicationRecord
  include Container

  belongs_to :plate

  validates :position, presence: true
end
