# frozen_string_literal: true

# Failed validations return unprocessable_entity
class PacbioRevioPlateValidator < ActiveModel::Validator
  def validate(record)
    # return unless the run is a Revio run
    return unless record.run.present? && record.run.system_name == 'Revio'

    existing_plates = Pacbio::Plate.where(
      sequencing_kit_box_barcode: record.sequencing_kit_box_barcode
    ).where.not(id: record.id)

    # return unless there are existing sequencing kit barcodes
    return if existing_plates.blank?

    validations = %i[validate_sequencing_kit_box_barcode_count
                     validate_sequencing_kit_box_barcode_positions]
    validations.each do |validation|
      next if record.errors.present?

      send(validation, record, existing_plates)
    end
  end

  def validate_sequencing_kit_box_barcode_count(record, existing_plates)
    return unless existing_plates.count > 1

    record.errors.add(:sequencing_kit_box_barcode, 'has already been used on 2 plates')
  end

  def validate_sequencing_kit_box_barcode_positions(record, existing_plates)
    common_positions = existing_plates.map(&:wells)
                                      .flatten.map(&:position) & record.wells.map(&:position)
    return unless common_positions.any?

    positions = common_positions.join(',')
    record.errors
          .add(:wells,
               "#{positions} have already been used for plate #{record.sequencing_kit_box_barcode}")
  end
end
