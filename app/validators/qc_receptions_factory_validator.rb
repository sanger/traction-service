# frozen_string_literal: true

# Failed validations return unprocessable_entity
# These are being validated before any entity is created
class QcReceptionsFactoryValidator < ActiveModel::Validator
  def validate(record)
    validations = %i[validate_qc_results_list validate_assay_type]

    validations.each do |validation|
      next if record.errors.present?

      send(validation, record)
    end
  end

  def validate_qc_results_list(record)
    # Check if array is not empty
    if record.qc_results_list.empty?
      record.errors.add :qc_results_list, :empty_array
      return
    end
    # Return if any object inside the qc_results_list array has values
    return nil if record.qc_results_list.any? { |value| !value.empty? }

    # Add error if the objects inside the qc_results_list array is empty
    record.errors.add :qc_results_list, :empty_array
    nil
  end

  def validate_assay_type(record)
    # Iterates through the qc_results_list array objects
    # checks if any qc attribute matches the assay type key
    # add error if not
    assay_types = QcAssayType.where(used_by: options[:used_by]).pluck(:id, :key)
    assay_types_hash = assay_types.to_h.invert
    record.qc_results_list.each do |qc_hash|
      return nil if qc_hash.any? { |qc, _value| assay_types_hash.keys.include? qc }
    end
    record.errors.add :qc_results_list, :invalid
    nil
  end
end
