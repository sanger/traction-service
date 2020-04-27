# frozen_string_literal: true

# Well
class Well < ApplicationRecord
  include Container

  belongs_to :plate, inverse_of: :wells

  validates :position, presence: true
end
