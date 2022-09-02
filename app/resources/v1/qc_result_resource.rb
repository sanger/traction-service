# frozen_string_literal: true

module V1
  # Exposes Qc Results for use by the UI
  class QcResultResource < JSONAPI::Resource
    attributes :labware_barcode, :sample_external_id, :value

    has_one :qc_assay_type

    filter :labware_barcode
  end
end
