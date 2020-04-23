# frozen_string_literal: true

# Plate
class Plate < ApplicationRecord
  include Labware

  has_many :wells, inverse_of: :plate, dependent: :destroy
end
