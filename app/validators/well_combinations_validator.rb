# frozen_string_literal: true

# Validator for well combinations
# Validates the combinations of Wells
class WellCombinationsValidator < ActiveModel::Validator
  include HasFilters

  attr_reader :options

  # @param [Hash] options
  # @option options [Array] :valid_combinations
  # @option options [Boolean] :exclude_marked_for_destruction
  def initialize(options)
    super
    @options = options
  end

  # @return [Array]
  # @example [['A1'], %w[A1 B1], %w[A1 B1 C1]]
  def valid_combinations
    @valid_combinations ||= options[:valid_combinations]
  end

  # @param [ActiveRecord::Base] record
  def validate(record)
    well_positions = filtered(record.wells).collect(&:position)

    return if valid_combinations.include?(well_positions)

    record.errors.add(:wells, 'must be in a valid order')
  end
end
