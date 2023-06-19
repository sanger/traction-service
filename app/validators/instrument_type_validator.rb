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
    validate_required_attributes(record, instrument_type['run'])
    validate_limit(record, :plates, instrument_type['plates'])
    record.plates.each do |plate|
      validate_required_attributes(plate, instrument_type['plates'])
      validate_limit(plate, :wells, instrument_type['wells'])
    end
  end

  def validate_required_attributes(record, configuration)
    configuration['required_attributes'].each do |attribute|
      record.errors.add(attribute, "can't be blank") if record.send(attribute).blank?
    end
  end

  def validate_limit(record, labware_type, configuration)
    minimum = configuration['minimum']
    maximum = configuration['maximum']
    if record.send(labware_type).length < minimum
      record.errors.add(labware_type,
                        "must have at least #{minimum} #{pluralize(minimum,
                                                                   labware_type)}")
    end
    return unless record.send(labware_type).length > maximum

    record.errors.add(labware_type,
                      "must have at most #{maximum} #{pluralize(maximum,
                                                                labware_type)}")
  end

  # This needs to be moved to locale file
  def pluralize(limit, text)
    return text.to_s.pluralize if limit > 1

    text.to_s.singularize
  end
end
