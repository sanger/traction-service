# frozen_string_literal: true

##
# validate SmrtLinkOptions by version:
#
# - This allows more flexible modification of fields by version
# - each version will have a set of validations
# - on validate it will loop through each of those validations
# - build a validator and validate the record for each specified attribute
# - the validations are standard ActiveRecord ones with specified options
# @example
#   smrt_link_option = { key: attribute_1, validations: { required: {},
#                        numericality: { greater_than_equal_to: 0,
#                        less_than_or_equal_to: 1}} }
# - This will then run each validator against the specified key
# @example
#   ActiveModel::Validations::NumericalityValidator.new(attributes: attribute_1,
#   greater_than_equal_to: 0, less_than_or_equal_to: 1).validate(record)
# - Any errors will be added to the record
# - The validator must be a recognised validator as per
# https://github.com/rails/rails/tree/main/activemodel/lib/active_model/validations
# - Or you need to create your own validator as per
# https://api.rubyonrails.org/classes/ActiveModel/Validator.html
class SmrtLinkOptionsValidator < ActiveModel::Validator
  def validate(record)
    # If the version is not present no point validating
    return if record&.run&.smrt_link_version.blank?

    # Retrieve the list of smrt link options for the specified version
    record.run.smrt_link_version.smrt_link_options.each do |smrt_link_option|
      # Retrieve the list of validations
      # each one will have a key and some options
      # key is the validator name
      # options is a hash e.g. { greater_than_equal_to: 1 }
      # see the validator docs in ActiveModel for the standard ones
      smrt_link_option.validations.each do |key, options|
        validator = validator_by_prefix(key)

        # We then need to create a new instance of the validator
        # and pass the options along with the attribute name which is the key
        # of the smrt link option
        # we need to symbolize the keys as some validators do not recognise string keys
        # for options
        instance = validator.new(options.merge(attributes: smrt_link_option.key).symbolize_keys)

        # finally validate the record
        # underneath it could be validate or validates_each
        instance.validate(record)
      end
    end
  end

  private

  # Get the validator class by prefix
  # @param prefix [String] the prefix of the validator
  # @return [Class] the class of the validator
  def validator_by_prefix(prefix)
    validator_class_name = "#{prefix.camelize}Validator"
    # Check if there is a custom validator first
    if Object.const_defined?(validator_class_name)
      validator_class_name.constantize
    else
      # If no custom validator then use an active model one
      "ActiveModel::Validations::#{validator_class_name}".constantize
    end
  end
end
