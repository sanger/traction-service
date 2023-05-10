# frozen_string_literal: true

# Validator to check the correct wells are being used
class WellPositionValidator < ActiveModel::Validator
  include ActiveModel::Validations

  VALID_WELLS = %w[A1 B1 C1 D1].freeze

  INVALID_COMBINATIONS = [
    %w[A1 D1],
    %w[A1 C1],
    %w[B1 D1],
    %w[A1 C1 D1],
    %w[A1 B1 D1]
  ].freeze

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

  # This validation checks that the wells only appear in certain combinations
  # no empty wells between libraries. It may be better to come up with an algorithm
  # i.e. check number of wells if it is more than 1 check no empty wells between libraries?
  def validate_contiguousness(record)
    # if we don't do this we get a 500 when there are no wells
    # there is already validation to check if there are wells
    return if record.wells.blank?

    well_positions = record.wells.collect(&:position)

    INVALID_COMBINATIONS.each do |combination|
      next unless well_positions == combination

      record.errors.add(:wells, "must be in the valid order #{VALID_WELLS}")
    end
  end
end
