# frozen_string_literal: true

# Validator for well combinations
# Validates the combinations of Wells
class WellCombinationsValidator < ActiveModel::Validator
  include ActiveModel::Validations

  attr_reader :valid_combinations

  # @param [Hash] options
  # @option options [Array] :valid_combinations
  def initialize(options)
    super
    @valid_combinations = options[:valid_combinations]
  end

  # @param [ActiveRecord::Base] record
  def validate(record)
    well_positions = record.wells.filter do |well|
      !well.marked_for_destruction?
    end.collect(&:position)

    return if valid_combinations.include?(well_positions)

    record.errors.add(:wells, 'must be in a valid order')
  end
end
