# frozen_string_literal: true

module V1
  # Exposes Qc Results for use by the UI
  class QcResultResource < JSONAPI::Resource
    attributes :labware_barcode, :sample_external_id, :value

    belongs_to :qc_assay_type
  end
end
