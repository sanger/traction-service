# frozen_string_literal: true

module V1
  # @todo This documentation does not yet include a detailed description of what this resource represents.
  # @todo This documentation does not yet include detailed descriptions for relationships, attributes and filters.
  # @todo This documentation does not yet include any example usage of the API via cURL or similar.
  #
  # @note Access this resource via the `/v1/qc_result` endpoint.
  #
  # Provides a JSON:API representation of {QcResult} and exposes valid qc result
  # for use by the UI.
  #
  # For more information about JSON:API see the [JSON:API Specifications](https://jsonapi.org/format/)
  # or look at the [JSONAPI::Resources](http://jsonapi-resources.com/) package for the service
  # implementation of the JSON:API standard.
  class QcResultResource < JSONAPI::Resource
    # @!attribute [rw] labware_barcode
    #   @return [String] the barcode of the labware
    # @!attribute [rw] sample_external_id
    #   @return [String] the external ID of the sample
    # @!attribute [rw] value
    #   @return [String] the value of the QC result
    attributes :labware_barcode, :sample_external_id, :value

    has_one :qc_assay_type

    filter :labware_barcode
  end
end
