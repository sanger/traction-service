# frozen_string_literal: true

module V1
  module Ont
    # rubocop:disable Layout/LineLength
    # Provides a JSON:API representation of {Ont::Flowcell} model.
    #
    # Flowcell is a cartridge containing a chip with nanopores used for DNA or
    # RNA sequencing by Oxford Nanopore Technologies (ONT). A flowcell is
    # associated with a sequencing run and a pool of samples to be sequenced.
    #
    # Primary relationships:
    # * pool {V1::PoolResource} - The pool loaded onto the flowcell.
    #
    # @note This resource is immutable: its endpoint will not accept `POST`, `PATCH`, or `DELETE` requests.
    # @note Access this resource via the `/v1/ont/flowcells/` endpoint.
    #
    # @example GET request to list all ONT flowcells
    #   curl -X GET http://localhost:3100/v1/ont/flowcells
    #
    # @example GET request to retrieve a specific ONT flowcell by ID
    #  curl -X GET "http://localhost:3100/v1/ont/flowcells/1"
    #
    # For more information about JSON:API see the [JSON:API Specifications](https://jsonapi.org/format/)
    # or look at the [JSONAPI::Resources](http://jsonapi-resources.com/) package
    # for the service implementation of the JSON:API standard.
    # rubocop:enable Layout/LineLength
    class FlowcellResource < JSONAPI::Resource
      model_name 'Ont::Flowcell'

      # @!attribute [r] flowcell_id
      #   @return [Integer] the ID of the flowcell
      # @!attribute [r] position
      #   @return [String] the position of the flowcell
      # @!attribute [r] ont_pool_id
      #   @return [Integer] the ID of the ONT pool
      attributes :flowcell_id, :position, :ont_pool_id

      has_one :pool, foreign_key: 'ont_pool_id', class_name: 'Pool'
    end
  end
end
