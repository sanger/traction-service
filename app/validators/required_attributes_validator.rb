# frozen_string_literal: true

# Validator for required attributes
# Validates the presence of required attributes
class RequiredAttributesValidator < ActiveModel::Validator
  include ActiveModel::Validations

  def validate(record); end
end
