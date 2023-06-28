# frozen_string_literal: true

# Validator for InstrumentType
# Validates the InstrumentType and its associated Plates and Wells
# Validates the presence of required attributes
# Validates the number of Plates and Wells
# Validates the positions of Wells
# Validates the combinations of Wells
class InstrumentTypeValidator < ActiveModel::Validator
  attr_reader :instrument_types, :instrument_type

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

    # e.g. if record is a Run, then root is :run
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

    # if the model is a has_many relationship
    if model[:validate_each]
      run_child_validations(record, model, models)
    else
      run_validations(record, model[:validations])
      # recursively validate the children
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
      # e.g. my_simple_validator = MySimpleValidator.new(validation[:options])
      validator = "#{key.camelize}Validator".constantize
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
  # It would be better to use the configuration to make this more flexible
  # but I need a bit more time to get it right
  # if we don't do this the run could be marked as valid
  # because it will not recognise nested errors
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
end
