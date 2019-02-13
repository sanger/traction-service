# frozen_string_literal: true

# Chip
class Chip < ApplicationRecord
  belongs_to :run, optional: true
  has_many :flowcells
end
