# frozen_string_literal: true

# Validator to check the correct wells are being used
# Validates the positions of Wells
class WellPositionsValidator < ActiveModel::Validator
  include HasFilters

  attr_reader :options

  # @param [Hash] options
  # @option options [Array] :valid_positions
  # @option options [Boolean] :exclude_marked_for_destruction
  def initialize(options)
    super
    @options = options
  end

  # @return [Array]
  # @example ['A1', 'B1', 'C1']
  def valid_positions
    @valid_positions ||= options[:valid_positions]
  end

  # @param [ActiveRecord::Base] record
  def validate(record)
    well_positions = filtered(record.wells).collect(&:position)

    return if (well_positions - valid_positions).empty?

    record.errors.add(:wells, "must be in positions #{valid_positions.join(',')}")
  end
end
