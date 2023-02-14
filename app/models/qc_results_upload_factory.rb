# frozen_string_literal: true

# Handles the logic of receiving a CSV and creating QC entities
class QcResultsUploadFactory
  include ActiveModel::Model

  attr_accessor :qc_results_upload

  validates :csv_data, :used_by, presence: true

  LR_DECISION_FIELD = 'LR EXTRACTION DECISION [ESP1]'
  TOL_DECISION_FIELD = 'TOL DECISION [ESP1]'
  TISSUE_TUBE_ID_FIELD = 'Tissue Tube ID'
  SANGER_SAMPLE_ID_FIELD = 'Sanger sample ID'

  LIST = [
    LR_DECISION_FIELD,
    TOL_DECISION_FIELD,
    TISSUE_TUBE_ID_FIELD,
    SANGER_SAMPLE_ID_FIELD
  ].freeze

  validates_with QcResultsUploadValidator, required_headers: LIST

  delegate :csv_data, :used_by, to: :qc_results_upload

  # @param [csv] csv rows
  # creates data from the initial csv
  def rows
    return unless qc_results_upload

    @rows ||= pivot_csv_data_to_obj
  end

  def create_entities!
    rows.each do |row_object|
      create_data(row_object)
    end
    true
  end

  # @param [Object] CSV row e.g. { col_header_1: row_1_col_1 }
  def create_data(row_object)
    # 1. Create QC Decisions
    qc_decisions = create_qc_decisions(row_object)

    # 2. Create QC Results
    qc_results = create_qc_results(row_object)

    # 3. Create QC Decision Results
    create_qc_decision_results(qc_results, qc_decisions[:lr_qc_decision],
                               qc_decisions[:tol_qc_decision])
  end

  def create_qc_decisions(row_object)
    # If required, create Long Read QC Decision
    if row_object[LR_DECISION_FIELD]
      lr_qc_decision = create_qc_decision!(row_object[LR_DECISION_FIELD], :long_read)
    end

    # If required, create TOL QC Decision
    if row_object[TOL_DECISION_FIELD]
      tol_qc_decision = create_qc_decision!(row_object[TOL_DECISION_FIELD], :tol)
    end

    { lr_qc_decision:, tol_qc_decision: }
  end

  # @returns [List] of created QcResults
  # @param [Object] CSV row e.g. { col_header_1: row_1_col_1 }
  def create_qc_results(row_object)
    # Get relevant QcAssayTypes, for used_by
    qc_assay_types = QcAssayType.where(used_by:)

    # Get the common data for each row
    tissue_tube_id = row_object[TISSUE_TUBE_ID_FIELD]
    sanger_sample_id = row_object[SANGER_SAMPLE_ID_FIELD]

    # Loop through QcAssayTypes
    qc_assay_types.map do |qc_assay_type|
      # TODO: clean up below comment
      # next returns nil if row is missing QcAssayType data
      # method retuns list.compact, as create_qc_results may contain nil objects
      # ingnore the value?
      next unless row_object[qc_assay_type.key]

      # Create a QcResult for each QcAssayType
      create_qc_result!(tissue_tube_id, sanger_sample_id, qc_assay_type.id,
                        row_object[qc_assay_type.key])
    end.compact
  end

  # create a qc decision for each decision maker
  def create_qc_decision_results(qc_results, lr_qc_decision, tol_qc_decision)
    # Always create Long Read QC Decision Results

    qc_results.each do |qc_result|
      # If required, create LR QC Decision Results
      if lr_qc_decision
        create_qc_decision_result!(qc_result, lr_qc_decision)
        build_qc_result_message(qc_result, :long_read)
      end

      # If required, create TOL QC Decision Results
      if tol_qc_decision
        create_qc_decision_result!(qc_result, tol_qc_decision)
        build_qc_result_message(qc_result, :tol)
      end
    end
  end

  def build_qc_result_message(qc_result, decision_made_by)
    messages << QcResultMessage.new(qc_result:, decision_made_by:)
  end

  # @return [QcDecision]
  def create_qc_decision!(status, decision_made_by)
    QcDecision.create!(status:, decision_made_by:)
  end

  # @return [QcResult]
  def create_qc_result!(labware_barcode, sample_external_id, qc_assay_type_id, value)
    QcResult.create!(labware_barcode:, sample_external_id:, qc_assay_type_id:, value:)
  end

  # @return [QcDecisionResult]
  def create_qc_decision_result!(qc_result, qc_decision)
    QcDecisionResult.create!(qc_result:, qc_decision:)
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

  # Qu: move out?

  # Pivots the CSV data
  # Returns a list of objects, where each object is a CSV row
  # @return [List] e.g. [{ col_header_1: row_1_col_1, col_header_2: row_1_col_2 }, ...]
  def pivot_csv_data_to_obj
    header_converter = proc do |header|
      assay_type = QcAssayType.find_by(label: header.strip)
      assay_type ? assay_type.key : header.strip
    end

    csv = CSV.new(csv_string_without_first_row, headers: true, header_converters: header_converter)

    arr_of_hashes = csv.to_a.map(&:to_hash)

    # Remove any rows which are missing the Tissue Tube ID, or which are controls
    arr_of_hashes.reject! do |row|
      row[TISSUE_TUBE_ID_FIELD].nil? || row[TISSUE_TUBE_ID_FIELD].match(/control/i)
    end
    arr_of_hashes
  end

  # Returns the CSV, with the first row (groupings) removed
  # @return [String] CSV
  def csv_string_without_first_row
    csv_data.split("\n")[1..].join("\n")
  end
end
