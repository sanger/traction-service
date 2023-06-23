# frozen_string_literal: true

# Validator for limits
# Validates the maximum and minimum values of attributes
class LimitsValidator < ActiveModel::Validator
  include ActiveModel::Validations

  attr_reader :minimum, :maximum, :attribute

  # @param [Hash] options
  # @option options [Integer] :minimum
  # @option options [Integer] :maximum
  # @option options [Symbol] :attribute
  def initialize(options)
    super
    @minimum = options[:minimum]
    @maximum = options[:maximum]
    @attribute = options[:attribute]
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
    return if record.send(attribute).size >= minimum

    record.errors.add(attribute, "must have at least #{minimum} #{attribute}")
  end

  # @param [ActiveRecord::Base] record
  # validates the maximum value of attribute
  def validate_maximum(record)
    return if record.send(attribute).size <= maximum

    record.errors.add(attribute, "must have at most #{maximum} #{attribute}")
  end
end
