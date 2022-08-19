# frozen_string_literal: true

module V1
  # Exposes Qc Assay types for use by the UI
  class QcAssayTypeResource < JSONAPI::Resource
    attributes :key, :label, :units
  end
end
