# frozen_string_literal: true

module V1
    module Ont
      # TubeResource
      class TubeResource < JSONAPI::Resource
        model_name 'Tube'
        attributes :barcode
        has_many :materials, class_name: 'ContainerMaterial', relation_name: :container_materials,
                             foreign_key_on: :related
        has_many :pools, relation_name: :ont_pools, class_name: 'Pool'
        has_many :requests, relation_name: :ont_requests
  
        # Filters
        filter :barcode, apply: ->(records, value, _options) { records.by_barcode(value) }
  
        def self.records(_options = {})
          ::Tube.by_pipeline(:ont)
        end
      end
    end
  end
  