# frozen_string_literal: true

# Validator to check the correct wells are being used
class DeprecatedWellPositionValidator < ActiveModel::Validator
  include ActiveModel::Validations

  # the standard set of well positions
  REFERENCE_WELLS = %w[A1 B1 C1 D1].freeze

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
    well_positions = wells_unless_marked_for_destruction(record).collect(&:position)
    return if (well_positions - REFERENCE_WELLS).empty?

    record.errors.add(:wells, "must be in positions #{REFERENCE_WELLS}")
    nil
  end

  # This validation checks that the there are no empty wells between libraries
  # e.g. A1, D1 is invalid whereas B1, C1 is valid
  def validate_contiguousness(record)
    # if we don't do this we get a 500 when there are no wells
    # there is already validation to check if there are wells
    # it is valid if there is a single well
    return if record.wells.blank? || record.wells.count == 1

    # build instance to check positions
    well_positions = WellPositionService.new({ wells: wells_unless_marked_for_destruction(record),
                                               reference_wells: REFERENCE_WELLS })

    # are the wells next to each other
    return unless well_positions.contiguous?

    # if the wells are not next to each other then it is not valid
    record.errors.add(:wells, "must be in the valid order #{REFERENCE_WELLS}")
  end

  private

  def wells_unless_marked_for_destruction(record)
    record.wells.filter { |well| !well.marked_for_destruction? }
  end

  # This inline class encapsulates the behaviour for checking the wells
  # We can leave it here for now but if we need to reuse it can be abstracted
  class WellPositionService
    include ActiveModel::Model

    # reference wells are the standard set of well positions
    # wells will have a position e.g. A1
    attr_accessor :reference_wells, :wells

    # extract each position into a list and sort it by position
    def positions
      wells.collect(&:position).sort
    end

    # find the correct index of each well position vs the reference well
    def indexes
      @indexes ||= positions.collect { |position| reference_wells.index(position) }
    end

    # reverse the indexes
    def reversed_indexes
      @reversed_indexes ||= indexes.reverse
    end

    # find the difference in position of each well
    # e.g. if wells are B1 and C1 then the difference is 1
    # whereas if the wells are B1 and D1 the difference is 2
    def index_differences
      @index_differences ||= [].tap do |differences|
        reversed_indexes.each_with_index do |value, index|
          differences << (value - reversed_indexes[index + 1]) unless value == reversed_indexes.last
        end
      end
    end

    # check whether all of the wells are next to each other
    def contiguous?
      index_differences.any? { |index| index > 1 }
    end
  end
end
