# frozen_string_literal: true

module V1
  module Ont
    # Provides a JSON:API representation of {Ont::Flowcell}.
    #
    ## Primary relationships:
    # * pool {V1::PoolResource} - The pool loaded onto the flowcell.
    #
    # @note Access this resource via the `/v1/ont/flowcells/` endpoint.
    #
    # @example
    #   curl -X GET http://localhost:3100/v1/ont/flowcells
    #   curl -X GET "http://localhost:3100/v1/ont/flowcells/1"
    #
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
