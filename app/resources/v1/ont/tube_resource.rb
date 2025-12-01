# frozen_string_literal: true

module V1
  module Ont
    # Provides a JSON:API representation of {Ont::Tube}.
    #
    # Filters:
    # * barcode - Filter tubes by their barcode.
    #
    ## Primary relationships:
    # * pools {V1::PoolResource} - The pools associated with the tube.
    # * requests {V1::RequestResource} - The requests associated with the tube.
    #

    # @note Access this resource via the `/v1/ont/tubes/` endpoint.
    #
    # @example
    #   curl -X GET http://localhost:3100/v1/ont/tubes
    #   curl -X GET "http://localhost:3100/v1/ont/tubes?filter[barcode]=TRAC-2-40,TRAC-2-41"
    #
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
