# frozen_string_literal: true

module V1
  module Pacbio
    # TubeResource
    class TubeResource < JSONAPI::Resource
      model_name 'Tube'
      attributes :barcode
      has_one :material, polymorphic: true, always_include_linkage_data: true

      # Filters
      filter :barcode, apply: ->(records, value, _options) { records.by_barcode(value) }

      def self.records(_options = {})
        ::Tube.by_pipeline(:pacbio)
      end
    end
  end
end
