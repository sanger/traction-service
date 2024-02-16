# frozen_string_literal: true

module V1
  module Pacbio
    # TubeResource
    class TubeResource < JSONAPI::Resource
      model_name 'Tube'
      attributes :barcode
      has_many :materials, class_name: 'ContainerMaterial', relation_name: :container_materials,
                           foreign_key_on: :related
      has_many :pools, relation_name: :pacbio_pools, class_name: 'Pool'
      # libraries has been used as opposed to library as the json api
      # resources relationship was breaking
      has_one :libraries, relation_name: :pacbio_library, class_name: 'Library'
      has_many :requests, relation_name: :pacbio_requests

      # Filters
      filter :barcode, apply: ->(records, value, _options) { records.by_barcode(value) }

      def self.records(_options = {})
        ::Tube.by_pipeline(:pacbio)
      end
    end
  end
end
