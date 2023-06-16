# frozen_string_literal: true

# Validator for InstrumentType
class InstrumentTypeValidator < ActiveModel::Validator
  include ActiveModel::Validations

  attr_reader :instrument_types, :instrument_type

  def initialize(options)
    super
    @instrument_types = options[:instrument_types]
  end

  def validate(record)
    @instrument_type = instrument_types.select do |_key, value|
      value['name'] == record.system_name
    end.values.first
    validate_required_attributes(record, 'run')
  end

  def validate_required_attributes(record, model)
    instrument_type[model]['required_attributes'].each do |attribute|
      record.errors.add(attribute, "can't be blank") if record.send(attribute).blank?
    end
  end
end
