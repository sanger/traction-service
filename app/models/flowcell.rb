# frozen_string_literal: true

# Flowcell
class Flowcell < ApplicationRecord
  belongs_to :library, optional: true
  validates :position, presence: true
  belongs_to :chip
end
