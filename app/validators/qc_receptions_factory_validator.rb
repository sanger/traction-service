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
    if record.qc_results_list.empty?
      record.errors.add :qc_results_list, 'Is empty'
      return
    end
    validate_each(record)
  end

  def validate_each(record)
    is_empty = true
    record.qc_results_list.each do |qc_hash|
      unless qc_hash.empty?
        is_empty = false
        break
      end
    end
    return unless is_empty

    record.errors.add :qc_results_list, 'Is empty'
    nil
  end

  def validate_assay_type(record)
    assay_types = QcAssayType.where(used_by: options[:used_by]).pluck(:id, :key)
    assay_types_hash = assay_types.to_h.invert
    record.qc_results_list.each do |qc_hash|
      qc_hash.each do |qc, _value|
        return nil if assay_types_hash.keys.include? qc
      end
    end
    record.errors.add :qc_results_list, 'No valid Qc fields'
    nil
  end
end
