# frozen_string_literal: true

# Well
class Well < ApplicationRecord
  include Container

  belongs_to :plate, inverse_of: :wells

  validates :position, presence: true

  def row
    position[0]
  end

  def column
    position[1..-1].to_i
  end
end
