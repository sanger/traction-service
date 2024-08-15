# frozen_string_literal: true

module V1
  module Ont
    # @todo This documentation does not yet include a detailed description of what this resource represents.
    # @todo This documentation does not yet include detailed descriptions for relationships, attributes and filters.
    # @todo This documentation does not yet include any example usage of the API via cURL or similar.
    #
    # @note Access this resource via the `/api/v1/ont/flowcell/` endpoint.
    #
    # Provides a JSON:API representation of {Ont::Flowcell}.
    #
    # For more information about JSON:API see the [JSON:API Specifications](https://jsonapi.org/format/)
    # or look at the [JSONAPI::Resources](http://jsonapi-resources.com/) package
    # for the service implementation of the JSON:API standard.
    class FlowcellResource < JSONAPI::Resource
      model_name 'Ont::Flowcell'

      # @!attribute [rw] flowcell_id
      #   @return [Integer] the ID of the flowcell
      # @!attribute [rw] position
      #   @return [String] the position of the flowcell
      # @!attribute [rw] ont_pool_id
      #   @return [Integer] the ID of the ONT pool
      attributes :flowcell_id, :position, :ont_pool_id

      has_one :pool, foreign_key: 'ont_pool_id', class_name: 'Pool'
    end
  end
end
