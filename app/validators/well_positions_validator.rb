# frozen_string_literal: true

# Validator to check the correct wells are being used
# Validates the positions of Wells
class WellPositionsValidator < ActiveModel::Validator
  attr_reader :valid_positions, :exclude_marked_for_destruction

  # @param [Hash] options
  # @option options [Array] :valid_positions
  def initialize(options)
    super
    @valid_positions = options[:valid_positions]
    @exclude_marked_for_destruction = options[:exclude_marked_for_destruction] || false
  end

  # @param [ActiveRecord::Base] record
  def validate(record)
    well_positions = filtered(record).collect(&:position)

    return if (well_positions - valid_positions).empty?

    record.errors.add(:wells, "must be in positions #{valid_positions.join(',')}")
  end

  private

  def filtered(record)
    return record.wells unless exclude_marked_for_destruction

    record.wells.filter { |well| !well.marked_for_destruction? }
  end
end
