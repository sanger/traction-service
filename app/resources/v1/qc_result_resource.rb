# frozen_string_literal: true

module V1
  #
  # @note This endpoint can't be directly accessed via the `/v1/qc_results/` endpoint
  # as it is not currently used.
  #
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
