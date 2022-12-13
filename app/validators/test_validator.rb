# frozen_string_literal: true

# WIP
# validate_body requires @rows

# To use, include validates_with TestValidator in class
class TestValidator < ActiveModel::Validator
  include ActiveModel::Validations

  # Refactor
  # These are required headers
  LR_DECISION_FIELD = 'LR EXTRACTION DECISION [ESP1]'
  TOL_DECISION_FIELD = 'TOL DECISION [ESP1]'
  TISSUE_TUBE_ID_FIELD = "Tissue Tube ID"
  SANGER_SAMPLE_ID_FIELD = 'Sanger sample ID'

  def validate(record)
    validate_used_by(record)
    validate_headers(record)
    validate_fields(record)
    validate_body(record)
  end

  def validate_used_by(record)
    qc_assay_types = QcAssayType.where(used_by: record.used_by)

    if qc_assay_types.size === 0
      record.errors.add :used_by, "No QcAssayTypes belong to used_by value"
      return
    end
  end

  def validate_headers(record)
    return if record.csv_data.blank?

    # Is this actually checking anything?
    header_row = record.csv_data.split("\n")[1]
    unless header_row
      record.errors.add :csv_data, 'Missing headers'
      return
    end

    # Remove whitespace and empty headers
    @headers = header_row.split(',').map(&:strip).compact_blank

    # Case sensitive
    # e.g. "Genome Size" != "Genome size"
    return if @headers.count == @headers.uniq.count

    record.errors.add :csv_data, 'Contains duplicated headers'
    nil
  end

  def validate_fields(record)
    required_headers = [LR_DECISION_FIELD, TOL_DECISION_FIELD, TISSUE_TUBE_ID_FIELD, SANGER_SAMPLE_ID_FIELD]

    return if (required_headers - @headers).empty?

    record.errors.add :csv_data, "Missing required header: #{(required_headers - @headers)}"
  end

  def validate_body(record)
    return if record.csv_data.blank?

    data_rows = record.csv_data.split("\n")[2..]
    record.errors.add :csv_data, 'Missing data' if data_rows.blank?

    # Ensure each row has required data
    @rows.each do |row_object|
      required_data = [LR_DECISION_FIELD, TISSUE_TUBE_ID_FIELD, SANGER_SAMPLE_ID_FIELD]

      required_data.each do | header|
        record.errors.add :csv_data, "Missing data: #{header}" if row_object[header].blank?
      end
    end
  end
end
