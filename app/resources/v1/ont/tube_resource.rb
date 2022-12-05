# frozen_string_literal: true

module V1
  module Ont
    # TubeResource
    class TubeResource < JSONAPI::Resource
      model_name 'Tube'
      attributes :barcode
      has_many :pools, relation_name: :ont_pools, class_name: 'Pool'
      has_many :requests, class_name: 'Request', relation_name: :ont_requests,
                          foreign_key_on: :related

      # Filters
      filter :barcode, apply: ->(records, value, _options) { records.by_barcode(value) }

      def self.records(_options = {})
        ::Tube.by_pipeline(:ont)
      end
    end
  end
end
