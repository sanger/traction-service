# frozen_string_literal: true

# Validator to check the correct wells are being used
class WellPositionValidator < ActiveModel::Validator
  include ActiveModel::Validations

  VALID_WELLS = %w[A1 B1 C1 D1].freeze
  PARTIAL_PLATE = %w[C1 D1].freeze

  def validate(record)
    return unless record.wells

    validations = %i[validate_positions validate_contiguousness]

    validations.each do |validation|
      next if record.errors.present?

      send(validation, record)
    end
  end

  # This validation ensures that the wells are in correct positions
  def validate_positions(record)
    well_positions = record.wells.collect(&:position)
    return if (well_positions - VALID_WELLS).empty?

    record.errors.add(:wells, "must be in positions #{VALID_WELLS}")
    nil
  end

  # This validation ensures that the wells chosen are continuous in alphabetical order
  # Compares the order of received well positions against the valid wells positions
  def validate_contiguousness(record)
    # if we don't do this we get a 500 when there are no wells
    # there is already validation to check if there are wells
    return if record.wells.blank?

    reversed_valid_wells = VALID_WELLS.reverse
    well_positions = record.wells.collect(&:position)
    reversed_received_wells = well_positions.reverse

    # a partial plate is where the last 2 wells are filled
    return if reversed_received_wells == PARTIAL_PLATE.reverse

    # find the last well position received and find its position in the valid wells array
    position = reversed_valid_wells.index(reversed_received_wells[0])
    # get the correct order the well positions should be
    valid_well_order = reversed_valid_wells[position + 1..]
    # get the order of the well positions received
    received_well_order = reversed_received_wells[1..]
    # compare the valid and received order of wells
    return if valid_well_order == received_well_order

    record.errors.add(:wells, "must be in the valid order #{VALID_WELLS}")
    nil
  end
end
