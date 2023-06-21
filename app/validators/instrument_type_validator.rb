# frozen_string_literal: true

# Validator for InstrumentType
class InstrumentTypeValidator < ActiveModel::Validator
  include ActiveModel::Validations

  attr_reader :instrument_types, :instrument_type

  def initialize(options)
    super
    @instrument_types = options[:instrument_types].with_indifferent_access
  end

  def validate(record)
    self.instrument_type = record

    validate_required_attributes(record, instrument_type['run'])
    validate_limits(record, :plates, instrument_type['plates']['limits'])
    validate_plates(record)
  end

  def validate_plates(record)
    record.plates.each do |plate|
      validate_required_attributes(plate, instrument_type['plates'])
      validate_limits(plate, :wells, instrument_type['wells']['limits'])
      validate_wells(plate, instrument_type['wells'])
    end
  end

  def validate_wells(record, configuration)
    well_positions = record.wells.filter do |well|
      !well.marked_for_destruction?
    end.collect(&:position).sort
    
    validate_well_positions(record, well_positions,configuration['positions'])
    validate_well_combinations(record, well_positions, configuration['combinations'])
  end

  def validate_required_attributes(record, configuration)
    return if configuration['required_attributes'].blank?

    configuration['required_attributes'].each do |attribute|
      record.errors.add(attribute, "can't be blank") if record.send(attribute).blank?
    end
  end

  def validate_limits(record, labware_type, limits)
    if record.send(labware_type).length < limits[:minimum]
      record.errors.add(labware_type,
                        "must have at least #{limits[:minimum]} #{pluralize(limits[:minimum],
                                                                            labware_type)}")
    end
    return unless record.send(labware_type).length > limits[:maximum]

    record.errors.add(labware_type,
                      "must have at most #{limits[:maximum]} #{pluralize(limits[:maximum],
                                                                         labware_type)}")
  end

  def validate_well_positions(record, well_positions, valid_positions)
    return if valid_positions.blank?

    return if (well_positions - valid_positions).empty?

    record.errors.add(:wells, "must be in positions #{valid_positions}")
  end

  def validate_well_combinations(record, well_positions, valid_combinations)
    return if valid_combinations.blank?

    return if valid_combinations.include?(well_positions)

    record.errors.add(:wells, 'must be in a valid order')
  end

  def instrument_type=(record)
    @instrument_type = instrument_types.select do |_key, value|
      value['name'] == record.system_name
    end.values.first
  end

  # This needs to be moved to locale file
  def pluralize(limit, text)
    return text.to_s.pluralize if limit > 1

    text.to_s.singularize
  end
end
