# frozen_string_literal: true

# Handles the logic of recieving a CSV and creating QC entities
class QcResultsUploadFactory
  include ActiveModel::Model

  attr_accessor :qc_results_upload

  delegate :csv_data, to: :qc_results_upload
  delegate :used_by, to: :qc_results_upload

  LR_DECISION_FIELD = 'LR EXTRACTION DECISION'
  TOL_DECISION_FIELD = 'TOL DECISION [Post-Extraction]'

  def create_entities!
    build
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
    qc_result_ids = create_qc_results(row_object)

    # 4. Always create Long Read QC Decision Results
    qc_result_ids.each do |qc_result_id|
      create_qc_decision_result!(qc_result_id, lr_qc_decison_id)
    end

    # ?? Refactor this so only 1 loop over qc_result_ids
    # 5. If required, create TOL QC Decision Results
    return unless tol_qc_decison_id

    qc_result_ids.each do |qc_result_id|
      create_qc_decision_result!(qc_result_id, tol_qc_decison_id)
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
      create_qc_result!(row_object['Tissue Tube ID'], row_object['Sanger sample ID'],
                        qc_assay_type.id, row_object[qc_assay_type.key]).id
    end
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
  def create_qc_decision_result!(qc_result_id, qc_decision_id)
    QcDecisionResult.create!(qc_result_id:, qc_decision_id:)
  end
end
