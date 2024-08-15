# frozen_string_literal: true

module V1
  # @todo This documentation does not yet include a detailed description of what this resource represents.
  # @todo This documentation does not yet include detailed descriptions for relationships, attributes and filters.
  # @todo This documentation does not yet include any example usage of the API via cURL or similar.
  #
  # @note Access this resource via the `/api/v1/qc_assay_type` endpoint.
  #
  # Provides a JSON:API representation of {QcAssayType} and exposes valid qc assay type options
  # for use by the UI.
  #
  # For more information about JSON:API see the [JSON:API Specifications](https://jsonapi.org/format/)
  # or look at the [JSONAPI::Resources](http://jsonapi-resources.com/) package for the service
  # implementation of the JSON:API standard.
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
