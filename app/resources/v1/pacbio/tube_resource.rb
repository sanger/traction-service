# frozen_string_literal: true

module V1
  module Pacbio
    # @todo This documentation does not yet include a detailed description of what this resource represents.
    # @todo This documentation does not yet include detailed descriptions for relationships, attributes and filters.
    # @todo This documentation does not yet include any example usage of the API via cURL or similar.
    #
    # @note Access this resource via the `/v1/pacbio/tube/` endpoint.
    #
    # Provides a JSON:API representation of {Tube}.
    #
    # For more information about JSON:API see the [JSON:API Specifications](https://jsonapi.org/format/)
    # or look at the [JSONAPI::Resources](http://jsonapi-resources.com/) package
    # for the service implementation of the JSON:API standard.
    class TubeResource < JSONAPI::Resource
      model_name 'Tube'

      # @!attribute [rw] barcode
      #   @return [String] the barcode of the tube
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
