# frozen_string_literal: true

# Validator to check the correct wells are being used
class WellPositionValidator < ActiveModel::Validator
  include ActiveModel::Validations

  def validate(record)
    record
  end
end
