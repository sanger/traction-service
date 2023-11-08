# frozen_string_literal: true

# Validator for required attributes
# Validates the presence of required attributes and versions
class RequiredAttributesValidator < ActiveModel::Validator
  attr_reader :required_attributes, :versions

  # @param [Hash] options
  # @option options [Array] :required_attributes
  def initialize(options)
    super

    @versions = options[:versions]
    @required_attributes = options[:required_attributes]
  end

  # @param [ActiveRecord::Base] record
  def validate(record)
    required_attributes.each do |required_attribute|
      validate_required_attribute(record, required_attribute)
    end
  end

  private

  # @param [ActiveRecord::Base] record
  # @param [Symbol] required_attribute
  def validate_required_attribute(record, required_attribute)
    return if record.send(required_attribute).present?

    record.errors.add(required_attribute, "can't be blank")
  end
end
