# frozen_string_literal: true

# Plate
class Plate < ApplicationRecord
  include Labware

  has_many :wells, inverse_of: :plate, dependent: :destroy

  # Plates are assumed to have wells with layout
  # A1 A2 A3 ...
  # B1 B2 ...
  # C1 ...
  # ...

  # sorts as: A1 B1 C1 ... A2 B2 ...
  def wells_by_column_then_row
    wells.sort { |a, b| a.column == b.column ? a.row <=> b.row : a.column <=> b.column }
  end

  # sorts as: A1 A2 A3 ... B1 B2 ...
  def wells_by_row_then_column
    wells.sort { |a, b| a.row == b.row ? a.column <=> b.column : a.row <=> b.row }
  end
end
