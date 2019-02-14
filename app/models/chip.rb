# frozen_string_literal: true

# Chip
class Chip < ApplicationRecord
  belongs_to :run, optional: true
  has_many :flowcells

  after_save :create_flowcells

  def create_flowcells
    Flowcell.create(position: 1, chip: self)
    Flowcell.create(position: 2, chip: self)
  end
end
