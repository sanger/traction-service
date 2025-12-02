# frozen_string_literal: true

module V1
  # `MultiPoolResource` provides a **JSON:API** representation of the `MultiPool` model.
  # It allows API clients to query, filter, and retrieve multi-pool-related information.
  #
  # @note Access this resource via the `/v1/multi_pools` endpoint.
  #
  # Provides a JSON:API representation of {MultiPool} and exposes valid request
  # for use by the UI.
  #
  # For more information about JSON:API see the [JSON:API Specifications](https://jsonapi.org/format/)
  # or look at the [JSONAPI::Resources](http://jsonapi-resources.com/) package for the service
  # implementation of the JSON:API standard.
  class MultiPoolResource < JSONAPI::Resource
    # @!attribute [rw] pipeline
    #  @return [String] the pipeline associated with the multi_pool .e.g. "Pacbio" or "Ont"
    # @!attribute [rw] pool_method
    #  @return [Integer] the method used for pooling
    # @!attribute [rw] created_at
    #   @return [String] the creation date of the multi_pool in US format
    attributes :pool_method, :pipeline, :created_at
    # @!attribute [r] number_of_pools
    #  @return [Integer] a computed number of pools in the multi_pool
    attribute :number_of_pools, readonly: true

    has_many :multi_pool_positions, always_include_optional_linkage_data: true

    def created_at
      @model.created_at.to_fs(:us)
    end
  end
end
