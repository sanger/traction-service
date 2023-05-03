# frozen_string_literal: true

# Validator to check the correct wells are being used
class WellPositionValidator < ActiveModel::Validator
  include ActiveModel::Validations

  VALID_WELLS = %w[A1 B1 C1 D1].freeze

  def validate(record)
    well_positions = record.wells.collect(&:position)

    # are the wells in the correct positions?
    return if (well_positions - VALID_WELLS).empty?

    record.errors.add(:wells, "must be in positions #{VALID_WELLS}")
  end
end
