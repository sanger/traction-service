# frozen_string_literal: true

# Validator for sequencing kit box barcodes
# Validates the sequencing kit box barcodes for Revio runs
class SequencingKitBoxBarcodeValidator < ActiveModel::Validator
  include HasFilters

  attr_reader :options

  # @param [Hash] options
  # @option options [Integer] :max_number_of_plates
  def initialize(options)
    super
    @options = options
  end

  def validate(record)
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

  # @param [Plate] record
  # @param [Array<Plate>] existing_plates
  # For a given sequencing kit box barcode, check if the number of plates is less than the max
  # number of plates allowed
  def validate_sequencing_kit_box_barcode_count(record, existing_plates)
    return unless existing_plates.count >= options[:max_number_of_plates]

    record
      .errors.add(:plates,
                  'sequencing kit box barcode has already been used on ' \
                  "#{options[:max_number_of_plates]} plates")
  end

  # @param [Plate] record
  # @param [Array<Plate>] existing_plates
  # For a given sequencing kit box barcode, check if the positions have already been used
  def validate_sequencing_kit_box_barcode_positions(record, existing_plates)
    # filter wells based on exclusions
    record_wells = filtered(record.wells)
    # Get the common positions between the existing plates and the record wells
    common_positions = existing_plates.map(&:wells).flatten.map(&:position) &
                       record_wells.map(&:position)
    return unless common_positions.any?

    positions = common_positions.join(',')
    record.errors
          .add(:plates,
               "#{positions} have already been used for plate #{record.sequencing_kit_box_barcode}")
  end
end
