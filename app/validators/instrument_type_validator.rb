# frozen_string_literal: true

# Validator for InstrumentType
# Validates the InstrumentType and its associated Plates and Wells
# Validates the presence of required attributes
# Validates the number of Plates and Wells
# Validates the positions of Wells
# Validates the combinations of Wells
# TODO: Move the error messages to locale file
# TODO: It functions but it is not pretty
class InstrumentTypeValidator < ActiveModel::Validator
  include ActiveModel::Validations

  attr_reader :instrument_types, :instrument_type, :run

  # @param [Hash] options
  # @option options [Hash] :instrument_types
  def initialize(options)
    super
    @instrument_types = options[:instrument_types].with_indifferent_access
  end

  # @param [Run] record
  def validate(record)
    self.instrument_type = record

    @run = record

    return if instrument_type.blank?

    validate_required_attributes(record, instrument_type['run'])
    validate_limits(record, :plates, instrument_type['plates']['limits'])
    validate_plates(record)
  end

  # @param [Run] record
  # validates the presence of required attributes
  # validates the number of Wells
  def validate_plates(record)
    record.plates.each do |plate|
      validate_required_attributes(plate, instrument_type['plates'])
      validate_limits(plate, :wells, instrument_type['wells']['limits'],
                      "plate #{plate.plate_number} ")
      validate_wells(plate, instrument_type['wells'])
    end
  end

  # @param [Plate] record
  # @param [Hash] configuration
  # validates the positions of Wells
  # validates the combinations of Wells
  def validate_wells(record, configuration)
    well_positions = record.wells.filter do |well|
      !well.marked_for_destruction?
    end.collect(&:position).sort

    validate_well_positions(record, well_positions, configuration['positions'])
    validate_well_combinations(record, well_positions, configuration['combinations'])
  end

  private

  # @param [Run | Plate] record
  # @param [Hash] configuration
  # validates the presence of required attributes
  def validate_required_attributes(record, configuration)
    return if configuration['required_attributes'].blank?

    configuration['required_attributes'].each do |attribute|
      record.errors.add(attribute, "can't be blank") if record.send(attribute).blank?
    end
  end

  # @param [Run | Plate] record
  # @param [Symbol] labware_type
  # @param [Hash] limits
  # validates the number of Plates or Wells
  def validate_limits(record, labware_type, limits, message_prefix = nil)
    # binding.pry
    if record.send(labware_type).length < limits[:minimum]
      run.errors.add(labware_type,
                     "#{message_prefix}must have at least #{limits[:minimum]}
                     #{pluralize(limits[:minimum], labware_type)}")
    end
    return unless record.send(labware_type).length > limits[:maximum]

    run.errors.add(labware_type,
                   "#{message_prefix}must have at most #{limits[:maximum]}
                   #{pluralize(limits[:maximum], labware_type)}")
  end

  # @param [Plate] plate
  # @param [Hash] configuration
  # validates the positions of Wells
  def validate_well_positions(plate, well_positions, valid_positions)
    return if valid_positions.blank?

    return if (well_positions - valid_positions).empty?

    run.errors.add(:plates,
                   "plate #{plate.plate_number} wells must be in positions #{valid_positions}")
  end

  # @param [Plate] plate
  # @param [Hash] configuration
  # validates the combinations of Wells
  def validate_well_combinations(plate, well_positions, valid_combinations)
    return if valid_combinations.blank?

    return if valid_combinations.include?(well_positions)

    run.errors.add(:plates, "plate #{plate.plate_number} wells must be in a valid order")
  end

  # @param [Run] record
  # sets the instrument_type
  # @return [Hash]
  def instrument_type=(record)
    @instrument_type = instrument_types.select do |_key, value|
      value['name'] == record.system_name
    end.values.first
  end

  # This needs to be moved to locale file
  # @param [Integer] limit
  # @param [String] text
  # @return [String]
  # returns the plural or singular form of a word
  def pluralize(limit, text)
    return text.to_s.pluralize if limit > 1

    text.to_s.singularize
  end
end
