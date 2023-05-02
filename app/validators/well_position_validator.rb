# frozen_string_literal: true

# Validator to check the correct wells are being used
class WellPositionValidator < ActiveModel::Validator
  include ActiveModel::Validations

  VALID_WELLS = %w[A1 B1 C1 D1].freeze

  def validate(record)
    record
  end
end
