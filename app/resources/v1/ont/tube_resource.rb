# frozen_string_literal: true

module V1
  module Ont
    # @todo This documentation does not yet include a detailed description of what this resource represents.
    # @todo This documentation does not yet include detailed descriptions for relationships, attributes and filters.
    # @todo This documentation does not yet include any example usage of the API via cURL or similar.
    #
    # @note Access this resource via the `/v1/ont/tubes/` endpoint.
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
      # @!attribute [rw] pools
      #   @return [Array<Pool>] the pools associated with the tube
      # @!attribute [rw] requests
      #   @return [Array<Request>] the requests associated with the tube
      attributes :barcode
      has_many :pools, relation_name: :ont_pools, class_name: 'Pool'
      has_many :requests, class_name: 'Request', relation_name: :ont_requests,
                          foreign_key_on: :related

      # Filters
      filter :barcode, apply: lambda { |records, value, _options|
        records.by_barcode(value.map { |bc| bc.strip.upcase })
      }

      def self.records(_options = {})
        ::Tube.by_pipeline(:ont)
      end
    end
  end
end
