# frozen_string_literal: true

# Validator to check the correct wells are being used
class WellPositionValidator < ActiveModel::Validator
  include ActiveModel::Validations

  VALID_WELLS = %w[A1 B1 C1 D1].freeze

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

  # This validation checks that the there are no empty wells between libraries
  # e.g. A1, D1 is invalid whereas B1, C1 is valid
  def validate_contiguousness(record)
    # if we don't do this we get a 500 when there are no wells
    # there is already validation to check if there are wells
    # it is valid if there is a single well
    return if record.wells.blank? || record.wells.count == 1

    # get the position for each well in an array
    well_positions = record.wells.collect(&:position)

    # find the correct index of each well position vs the valid well and reverse it
    # we need to reverse it otherwise we get negative indexes
    reversed_indexes = well_positions.collect { |position| VALID_WELLS.index(position) }.reverse

    # get the differences in the indexes for each well
    index_differences = find_index_differences(reversed_indexes)

    # if all of the wells are next to each other and they are valid i.e. difference is 1
    return unless index_differences.any? { |index| index > 1 }

    # if the wells are not next to each other then it is not valid
    record.errors.add(:wells, "must be in the valid order #{VALID_WELLS}")
  end

  # find the difference in position of each well
  # e.g. if wells are B1 and C1 then the difference is 1
  # whereas if the wells are B1 and D1 the difference is 2
  def find_index_differences(indexes)
    [].tap do |index_differences|
      indexes.each_with_index do |value, index|
        index_differences << (value - indexes[index + 1]) unless value == indexes.last
      end
    end
  end
end
