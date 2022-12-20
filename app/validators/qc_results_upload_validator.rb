# frozen_string_literal: true

# Failed validations return unprocessable_entity
# These are being validated before any QC entity is created
class QcResultsUploadValidator < ActiveModel::Validator
  include ActiveModel::Validations

  def validate(record)
    validations = %i[validate_used_by validate_csv_data validate_rows validate_headers
                     validate_fields validate_body]

    validations.each do |validation|
      next if record.errors.present?

      send(validation, record)
    end
  end

  def validate_used_by(record)
    qc_assay_types = QcAssayType.where(used_by: record.used_by)
    return unless qc_assay_types.empty?

    record.errors.add :used_by, 'No QcAssayTypes belong to used_by value'
    nil
  end

  def validate_csv_data(record)
    return if record.csv_data.present?

    record.errors.add :csv_data, 'Is missing'
    nil
  end

  def validate_rows(record)
    @header_row = record.csv_data.split("\n")[1]
    unless @header_row
      record.errors.add :csv_data, 'Missing header row'
      return
    end

    data_rows = record.csv_data.split("\n")[2..]
    return if data_rows.present?

    record.errors.add :csv_data, 'Missing data rows'
    nil
  end

  def validate_headers(record)
    # Remove whitespace and empty headers
    @headers = @header_row.split(',').map(&:strip).compact_blank

    # Case sensitive
    # e.g. "Genome Size" != "Genome size"
    return unless @headers.count != @headers.uniq.count

    record.errors.add :csv_data, 'Contains duplicated headers'
    nil
  end

  def validate_fields(record)
    required_headers = options[:required_headers].pluck(:name)
    missing_headers = (required_headers - @headers)
    return if missing_headers.empty?

    record.errors.add :csv_data,
                      "Missing required headers: #{missing_headers.join(',')}"
    nil
  end

  def validate_body(record)
    required_data = options[:required_headers].collect do |h|
      h[:name] if h[:require_value] == true
    end.compact

    # Ensure each row has required data record.
    record.rows.each do |row_object|
      required_data.each do |header|
        record.errors.add :csv_data, "Missing data: #{header}" if row_object[header].blank?
      end
    end
  end
end
