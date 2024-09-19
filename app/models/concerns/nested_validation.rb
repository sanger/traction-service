# frozen_string_literal: true

#
# Module NestedValidation provides an ActiveModel compatible
# version of validates associated. Unlike the active model
# version however it actually propagates the error outwards.
#
# Set the optional, flatten_keys argument to false to maintain the association
# name in the error. Eg. errors.add('association.attribute', 'message')
#
# Usage:
#
# class MyHappyClass
#   extend NestedValidation
#
#   validates_nested :my_other_active_model_object, flatten_keys: false
#
# end
#
module NestedValidation
  #
  # Validates associated records and propagates the errors back onto the parent
  # object
  #
  class NestedValidator < ActiveModel::EachValidator
    def initialize(options)
      @flatten_keys = options.fetch(:flatten_keys, true)
      super
    end

    def validate_each(record, attribute, value)
      case value
      when Array
        value.each_with_index { |nested, index| validate_one(nested, record, attribute, index) }
      when nil
        nil # Do nothing
      else
        validate_one(value, record, attribute)
      end
    end

    private

    def validate_one(value, record, attribute, index = nil)
      return if value.valid?(options[:context])

      add_errors(value, record, attribute, index)
    end

    def add_errors(nested, record, attribute, index)
      nested.errors.each do |error|
        if @flatten_keys
          record.errors.add(error.attribute, error.message)
        else
          attribute_address = [attribute, index, error.attribute].compact.join('/').chomp('/base')
          record.errors.add(attribute_address, error.message)
        end
      end
    end
  end

  #
  # Records of this class will call valid? on any associations provided
  # as attr_names. Errors on these records will be propagated out
  # @param attr_names [Symbol] One or more associations to validate
  #
  # @return [NestedValidator]
  def validates_nested(*attr_names)
    validates_with NestedValidator, _merge_attributes(attr_names)
  end
end
