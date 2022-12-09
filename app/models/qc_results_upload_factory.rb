# frozen_string_literal: true

# Handles the logic of recieving a CSV and creating QC entities
class QcResultsUploadFactory
  include ActiveModel::Model

  attr_accessor :qc_results_upload

  delegate :csv_data, to: :qc_results_upload
  delegate :used_by, to: :qc_results_upload

  # These have to match the CSV LR and TOL decision column headers
  LR_DECISION_FIELD = 'LR EXTRACTION DECISION [ESP1]'
  TOL_DECISION_FIELD = 'TOL DECISION [ESP1]'

  # Validations return unprocessable_entity if not present
  validates :csv_data, :used_by, presence: true
  validate :validate_headers, :validate_body

  def create_entities!
    build
    true
  end

  def validate_headers
    return if csv_data.blank?

    header_row = csv_data.split("\n")[1]
    unless header_row
      errors.add :csv_data, 'Missing headers'
      return
    end

    headers = header_row.split(',')

    # Case sensitive
    # e.g. "Genome Size" != "Genome size"
    return if headers.count == headers.uniq.count

    errors.add :csv_data, 'Contains duplicated headers'
    nil
  end

  def validate_body
    return if csv_data.blank?

    data_rows = csv_data.split("\n")[2..]
    errors.add :csv_data, 'Missing data' if data_rows.blank?
  end

  # Returns the CSV, with the first row (groupings) removed
  # @return [String] CSV
  def csv_string_without_groups
    csv_data.split("\n")[1..].join("\n")
  end

  # Pivots the CSV data
  # Returns a list of objects, where each object is a CSV row
  # @return [List] e.g. [{ col_header_1: row_1_col_1, col_header_2: row_1_col_2 }, ...]
  def pivot_csv_data_to_obj
    header_converter = proc do |header|
      assay_type = QcAssayType.find_by(label: header.strip)
      assay_type ? assay_type.key : header
    end

    csv = CSV.new(csv_string_without_groups, headers: true, header_converters: header_converter,
                                             converters: :all)

    csv.to_a.map(&:to_hash)
  end

  # Loops through the Pivotted CSV data
  def build
    pivot_csv_data_to_obj.each do |row_object|
      create_data(row_object)
    end
  end

  # @param [Object] CSV row e.g. { col_header_1: row_1_col_1 }
  def create_data(row_object)
    # 1. Always create Long Read QC Decision
    lr_qc_decison_id = create_qc_decision!(row_object[LR_DECISION_FIELD], :long_read).id

    # 2. If required, create TOL QC Decision
    if row_object[TOL_DECISION_FIELD]
      tol_qc_decison_id = create_qc_decision!(row_object[TOL_DECISION_FIELD], :tol).id
    end

    # 3. Create QC Results
    qc_results = create_qc_results(row_object)

    # 4. Always create Long Read QC Decision Results
    qc_results.each do |qc_result|
      create_qc_decision_result!(qc_result.id, lr_qc_decison_id)
      messages << QcResultMessage.new(qc_result:, decision_made_by: :long_read)

      # 5. If required, create TOL QC Decision Results
      if tol_qc_decison_id
        create_qc_decision_result!(qc_result.id, tol_qc_decison_id)
        messages << QcResultMessage.new(qc_result:, decision_made_by: :tol)
      end
    end
  end

  # @returns [List] of created QcResult id's
  # @param [Object] CSV row e.g. { col_header_1: row_1_col_1 }
  def create_qc_results(row_object)
    # Get relevant QcAssayTypes, for used_by
    qc_assay_types = QcAssayType.where(used_by:)

    # Loop through QcAssayTypes
    # Create a QcResult for each QcAssayType
    qc_assay_types.map do |qc_assay_type|
      # Skip, to not errro,  if the row is missing the QC Assay Type data
      next unless row_object[qc_assay_type.key]

      create_qc_result!(row_object['Tissue Tube ID'], row_object['Sanger sample ID'],
                        qc_assay_type.id, row_object[qc_assay_type.key])
    end
  end

  # @return [QcDecision]
  # Returns status code: 500 if fail to create
  def create_qc_decision!(status, decision_made_by)
    QcDecision.create!(status:, decision_made_by:)
  end

  # @return [QcResult]
  # Returns status code: 500 if fail to create
  def create_qc_result!(labware_barcode, sample_external_id, qc_assay_type_id, value)
    QcResult.create!(labware_barcode:, sample_external_id:, qc_assay_type_id:, value:)
  end

  # @return [QcDecisionResult]
  # Returns status code: 500 if fail to create
  def create_qc_decision_result!(qc_result_id, qc_decision_id)
    QcDecisionResult.create!(qc_result_id:, qc_decision_id:)
  end

  # @returns [List] of all QcResultMessages - a different one is needed for each decision point
  def messages
    @messages ||= []
  end

  # A small wrapper class around QcResult for sending messages
  # It will return the qc result along with a decision determined by who has made the decision
  class QcResultMessage
    include ActiveModel::Model

    attr_accessor :qc_result, :decision_made_by

    delegate_missing_to :qc_result

    # @return [QcResult]
    # Returns the decision based on decision_made_by
    def qc_decision
      qc_result.qc_decisions.find_by(decision_made_by:)
    end
  end
end
