# frozen_string_literal: true

# Validator to check the correct wells are being used
# Validates the positions of Wells
class WellPositionsValidator < ActiveModel::Validator
  include ActiveModel::Validations

  attr_reader :valid_positions

  # @param [Hash] options
  # @option options [Array] :valid_positions
  def initialize(options)
    super
    @valid_positions = options[:valid_positions]
  end

  # @param [ActiveRecord::Base] record
  def validate(record)
    well_positions = record.wells.filter do |well|
      !well.marked_for_destruction?
    end.collect(&:position)

    return if (well_positions - valid_positions).empty?

    record.errors.add(:wells, "must be in positions #{valid_positions.join(',')}")
  end
end
