# frozen_string_literal: true

module V1
  # TubeResource
  class TubeResource < JSONAPI::Resource
    attributes :barcode
    has_one :material, polymorphic: true, always_include_linkage_data: true
  end
end
