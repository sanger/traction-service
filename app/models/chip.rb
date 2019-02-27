# frozen_string_literal: true

# Chip
class Chip < ApplicationRecord
  belongs_to :run, optional: true
  has_many :flowcells, dependent: :nullify

  after_create :create_flowcells

  def create_flowcells
    Flowcell.create([{position: 1, chip: self}, {position: 2, chip: self}])
  end
end
