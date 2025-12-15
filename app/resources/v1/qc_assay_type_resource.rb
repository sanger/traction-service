# frozen_string_literal: true

module V1
  # Provides a JSON:API representation of {QcAssayType}.
  #
  # QcAssayTypeResource exposes valid qc assay type options for use by the UI.
  # A QC Assay is a standard assay which is used to carry out QC e.g. "DNA vol (ul)"
  #
  # @note Access this resource via the `/v1/qc_assay_types` endpoint.
  #
  # @example
  #   curl -X GET http://localhost:3100/v1/qc_assay_types/
  #   curl -X GET http://localhost:3100/v1/qc_assay_types/1
  #
  class QcAssayTypeResource < JSONAPI::Resource
    # @!attribute [rw] key
    #   @return [String] the key of the QC assay type
    # @!attribute [rw] label
    #   @return [String] the label of the QC assay type
    # @!attribute [rw] units
    #   @return [String] the units of the QC assay type
    attributes :key, :label, :units
  end
end
