# frozen_string_literal: true

module V1
  module Saphyr
    # TubeResource
    class TubeResource < JSONAPI::Resource
      model_name 'Tube'
      attributes :barcode
      has_many :materials, class_name: 'ContainerMaterial', relation_name: :container_materials,
                           foreign_key_on: :related, always_include_linkage_data: true

      # Filters
      filter :barcode, apply: ->(records, value, _options) { records.by_barcode(value) }

      def self.records(_options = {})
        ::Tube.by_pipeline(:saphyr)
      end
    end
  end
end
