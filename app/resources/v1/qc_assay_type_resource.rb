# frozen_string_literal: true

module V1
  # rubocop:disable Layout/LineLength
  # Provides a JSON:API representation of {QcAssayType} model.
  #
  # QcAssayTypeResource exposes valid qc assay type options for use by the UI.
  # A QC Assay is a standard assay which is used to carry out QC e.g. "DNA vol (ul)"
  #
  # @note This resource is immutable: its endpoint will not accept `POST`, `PATCH`, or `DELETE` requests.
  # @note Access this resource via the `/v1/qc_assay_types` endpoint.
  #
  # @example GET request for all QcAssayType resources
  #   curl -X GET http://localhost:3100/v1/qc_assay_types/
  #
  # @example GET request for a single QcAssayType resource with ID 1
  #   curl -X GET http://localhost:3100/v1/qc_assay_types/1
  #
  # For more information about JSON:API see the [JSON:API Specifications](https://jsonapi.org/format/)
  # or look at the [JSONAPI::Resources](http://jsonapi-resources.com/) package for the service
  # implementation of the JSON:API standard.
  # rubocop:enable Layout/LineLength
  class QcAssayTypeResource < JSONAPI::Resource
    # @!attribute [r] key
    #   @return [String] the key of the QC assay type
    # @!attribute [r] label
    #   @return [String] the label of the QC assay type
    # @!attribute [r] units
    #   @return [String] the units of the QC assay type
    attributes :key, :label, :units
  end
end
