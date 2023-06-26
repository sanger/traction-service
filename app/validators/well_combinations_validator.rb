# frozen_string_literal: true

# Validator for well combinations
# Validates the combinations of Wells
class WellCombinationsValidator < ActiveModel::Validator
  include ActiveModel::Validations

  attr_reader :valid_combinations, :exclude_marked_for_destruction

  # @param [Hash] options
  # @option options [Array] :valid_combinations
  def initialize(options)
    super
    @valid_combinations = options[:valid_combinations]
    @exclude_marked_for_destruction = options[:exclude_marked_for_destruction] || false
  end

  # @param [ActiveRecord::Base] record
  def validate(record)
    well_positions = filtered(record).collect(&:position)

    return if valid_combinations.include?(well_positions)

    record.errors.add(:wells, 'must be in a valid order')
  end

  private

  def filtered(record)
    return record.wells unless exclude_marked_for_destruction

    record.wells.filter { |well| !well.marked_for_destruction? }
  end
end
