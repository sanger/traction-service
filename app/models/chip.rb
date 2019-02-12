# frozen_string_literal: true

# Chip
class Chip < ApplicationRecord
  validates :barcode, presence: true
  belongs_to :run, optional: true
  has_many :flowcells
end
