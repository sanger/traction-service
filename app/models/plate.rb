# frozen_string_literal: true

# Plate
class Plate < ApplicationRecord
  include Labware

  DEFAULT_SIZE = 96

  has_many :wells, inverse_of: :plate, dependent: :destroy do
    def located_at(position)
      if loaded?
        detect { |w| w.position == position } || build(position: position)
      else
        find_or_initialize_by(position: position)
      end
    end
  end

  # This validation probably *should* be always on. It doesn't seem to be violated in production
  # but engaging it does cause tests to fail.
  validates :barcode, presence: true, on: :reception

  scope :by_pipeline,
        lambda { |pipeline|
          joins(wells: :container_materials).where(
            'container_materials.material_type LIKE ?', "#{pipeline.capitalize}::%"
          ).distinct
        }

  scope :by_barcode, ->(*barcodes) { where(barcode: barcodes) }

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

  #
  # Compacts the provided well range into an easy to read summary.
  # e.g.. formatted_range(['A1', 'B1', 'C1','A2','A5','B5']) => 'A1-C1,A2,A5-B5'
  # Mostly this will just be start_well-end_well
  #
  # @param [Array<String>] wells Array of well names to format
  #
  # @return [String] A name describing the range
  #
  def formatted_range(wells)
    WellSorterService.formatted_range(wells, DEFAULT_SIZE)
  end
end
