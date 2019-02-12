# frozen_string_literal: true

# Flowcell
class Flowcell < ApplicationRecord
  has_one :library
  validates :position, presence: true
  belongs_to :chip
end
