# frozen_string_literal: true

# Failed validations return unprocessable_entity
# These are being validated before any QC entity is created
class QcResultsUploadValidator < ActiveModel::Validator
  include ActiveModel::Validations

  def validate(record)
    # DPL-478 Todo
    # Refactor to call below individually, and exit on any error
    # validate_used_by(record)
    # validate_headers(record)
    # validate_fields(record)
    # validate_body(record)

    # 1.
    # validate_used_by
    qc_assay_types = QcAssayType.where(used_by: record.used_by)
    if qc_assay_types.empty?
      record.errors.add :used_by, 'No QcAssayTypes belong to used_by value'
      return
    end

    # 2.
    # validate_headers
    if record.csv_data.blank?
      record.errors.add :csv_data, 'Is missing'
      return
    end

    header_row = record.csv_data.split("\n")[1]
    unless header_row
      record.errors.add :csv_data, 'Missing headers'
      return
    end

    # Remove whitespace and empty headers
    @headers = header_row.split(',').map(&:strip).compact_blank

    # Case sensitive
    # e.g. "Genome Size" != "Genome size"
    if @headers.count != @headers.uniq.count
      record.errors.add :csv_data, 'Contains duplicated headers'
      return
    end

    # 3.
    # validate_fields
    required_headers = options[:required_headers].pluck(:name)
    missing_headers = (required_headers - @headers)
    unless missing_headers.empty?
      record.errors.add :csv_data,
                        "Missing required headers: #{missing_headers.join(',')}"
      return
    end

    # 4.
    # validate_body
    required_data = options[:required_headers].collect do |h|
      h[:name] if h[:require_value] == true
    end.compact

    data_rows = record.csv_data.split("\n")[2..]
    if data_rows.blank?
      record.errors.add :csv_data, 'Missing data'
      return
    end

    # Ensure each row has required data record.
    record.rows.each do |row_object|
      required_data.each do |header|
        record.errors.add :csv_data, "Missing data: #{header}" if row_object[header].blank?
      end
    end
  end

  # def validate_used_by(record)
  #   # 1.
  #   # validate_used_by
  #   qc_assay_types = QcAssayType.where(used_by: record.used_by)
  #   if qc_assay_types.empty?
  #     record.errors.add :used_by, 'No QcAssayTypes belong to used_by value'
  #     return
  #   end
  # end

  # def validate_headers(record)
  #   # 2.
  #   # validate_headers
  #   if record.csv_data.blank?
  #     record.errors.add :csv_data, 'Is missing'
  #     return
  #   end

  #   # Is this actually checking anything?
  #   header_row = record.csv_data.split("\n")[1]
  #   unless header_row
  #     record.errors.add :csv_data, 'Missing headers'
  #     return
  #   end

  #   # Remove whitespace and empty headers
  #   @headers = header_row.split(',').map(&:strip).compact_blank

  #   # Case sensitive
  #   # e.g. "Genome Size" != "Genome size"
  #   if @headers.count != @headers.uniq.count
  #     record.errors.add :csv_data, 'Contains duplicated headers'
  #     return
  #   end
  # end

  # def validate_fields(record)
  #   required_headers = options[:required_headers].pluck(:name)
  #   missing_headers = (required_headers - @headers)
  #   unless missing_headers.empty?
  #     record.errors.add :csv_data,
  #                       "Missing required headers: #{missing_headers.join(',')}"
  #     return
  #   end
  # end

  # def validate_body(record)
  #   # 4.
  #   # validate_body
  #   required_data = options[:required_headers].collect do |h|
  #     h[:name] if h[:require_value] == true
  #   end.compact

  #   data_rows = record.csv_data.split("\n")[2..]
  #   if data_rows.blank?
  #     record.errors.add :csv_data, 'Missing data'
  #     return
  #   end

  #   # Ensure each row has required data record.
  #   record.rows.each do |row_object|
  #     required_data.each do |header|
  #       record.errors.add :csv_data, "Missing data: #{header}" if row_object[header].blank?
  #     end
  #   end
  # end
end
