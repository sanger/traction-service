# frozen_string_literal: true

# Validator for limits
# Validates the maximum and minimum values of attributes
class LimitsValidator < ActiveModel::Validator
  include HasFilters

  # @param [Hash] options
  # @option options [Integer] :minimum
  # @option options [Integer] :maximum
  # @option options [Symbol] :attribute
  # @option options [Boolean] :exclude_marked_for_destruction
  def initialize(options)
    super
    @options = options
  end

  # @return [Integer]
  def minimum
    @minimum ||= options[:minimum]
  end

  # @return [Integer]
  def maximum
    @maximum ||= options[:maximum]
  end

  # @return [Symbol]
  def attribute
    @attribute ||= options[:attribute]
  end

  # @param [ActiveRecord::Base] record
  def validate(record)
    return if record.send(attribute).nil?

    validate_minimum(record)
    validate_maximum(record)
  end

  private

  # @param [ActiveRecord::Base] record
  # validates the minimum value of attribute
  def validate_minimum(record)
    return if filtered(record.send(attribute)).size >= minimum

    record.errors.add(attribute, "must have at least #{minimum} #{pluralize(minimum, attribute)}")
  end

  # @param [ActiveRecord::Base] record
  # validates the maximum value of attribute
  def validate_maximum(record)
    return if filtered(record.send(attribute)).size <= maximum

    record.errors.add(attribute, "must have at most #{maximum} #{pluralize(maximum, attribute)}")
  end

  # @param [Integer] limit
  # @param [String] text
  # @return [String]
  # returns the plural or singular form of a word
  def pluralize(limit, text)
    return text.to_s.pluralize if limit > 1

    text.to_s.singularize
  end
end
