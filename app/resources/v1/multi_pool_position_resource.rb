# frozen_string_literal: true

module V1
  # `MultiPoolPositionResource` provides a **JSON:API** representation of the `MultiPoolPosition`
  # model.
  # It allows API clients to query, filter, and retrieve multi-pool-position-related information.
  #
  # @note Access this resource via the `/v1/multi_pool_positions` endpoint.
  #
  # Provides a JSON:API representation of {MultiPoolPosition} and exposes valid request
  # for use by the UI.
  #
  # For more information about JSON:API see the [JSON:API Specifications](https://jsonapi.org/format/)
  # or look at the [JSONAPI::Resources](http://jsonapi-resources.com/) package for the service
  # implementation of the JSON:API standard.
  class MultiPoolPositionResource < JSONAPI::Resource
    model_name 'MultiPoolPosition'

    # @!attribute [rw] position
    #  @return [String] the position within the multi_pool .e.g. "A1"
    # @!attribute [rw] pool_id
    #  @return [Integer] the id of the pool associated with this position
    # @!attribute [rw] pool_type
    # @return [String] the type of the pool associated with this position
    # @!attribute [rw] created_at
    #   @return [String] the creation date of the multi_pool_position in US format
    attributes :position, :pool_id, :pool_type, :created_at

    has_one :multi_pool

    has_one :pool, polymorphic: true,
                   polymorphic_types: %w[pacbio_pool ont_pool]

    has_one :pacbio_pool, class_name: 'Pacbio::Pool', relation_name: :pacbio_pool
    has_one :ont_pool, class_name: 'Ont::Pool', relation_name: :ont_pool

    def created_at
      @model.created_at.to_fs(:us)
    end

    def self.resource_klass_for(type)
      case type
      when 'pacbio_pool'
        type = 'Pacbio::Pool'
      when 'ont_pool'
        type = 'Ont::Pool'
      # TODO: This wont work for ONT
      when 'pools' # rubocop:disable Lint/DuplicateBranch
        type = 'Pacbio::Pool'
      end
      super
    end
  end
end
