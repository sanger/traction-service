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
  # validates the InstrumentType and its associated Plates and Wells
  def validate(record)
    self.instrument_type = record

    return if instrument_type.blank?

    @run = record

    validate_model(record.model_name.element.to_sym, record, instrument_type['models'])

    bubble_errors(record)
  end

  private

  # @param [Symbol] root - the root of the model e.g. :run
  # @param [Model] record - the model to validate
  # @param [Hash] models - the validations
  # validates the model and its children
  def validate_model(root, record, models)
    model = models[root]

    return if model[:validations].blank?

    if model[:validate_each]
      run_child_validations(record, model, models)
    else
      run_validations(record, model[:validations])
      if model[:children].present?
        validate_model(model[:children], record.send(model[:children]),
                       models)
      end
    end
  end

  # @param [Model] record - the model to validate
  # @param [Hash] validations - the validations
  # run each validation by calling the corresponding validator
  def run_validations(record, validations)
    validations.each do |key, validation|
      validator = "#{key.classify.pluralize}Validator".constantize
      instance = validator.new(validation[:options])
      instance.validate(record)
    end
  end

  # @param [Model] record - the model to validate
  # @param [Hash] model - the specific validations for the record
  # @param [Hash] models - all of the validations
  # run each validation by calling the corresponding validator
  def run_child_validations(record, model, models)
    record.each do |child|
      run_validations(child, model[:validations])
      validate_model(model[:children], child, models) if model[:children].present?
    end
  end

  # @param [Run] record
  # adds the errors from the Plates and Wells to the Run
  def bubble_errors(record)
    record.plates.each do |plate|
      next if plate.errors.empty?

      plate.errors.each do |error|
        record.errors.add(:plates,
                          "plate #{plate.plate_number} #{error.attribute} #{error.message}")
      end
    end
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
