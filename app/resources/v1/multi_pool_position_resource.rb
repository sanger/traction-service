# frozen_string_literal: true

module V1
  # `MultiPoolPositionResource` provides a **JSON:API** representation of the `MultiPoolPosition`
  # model.
  # It allows API clients to query, filter, and retrieve multi-pool-position-related information.
  #
  # @note This resource cannot be directly accessed. Reference via {V1::MultiPoolResource} includes
  # if required
  #
  # Relationships:
  # * multi_pool {V1::MultiPoolResource}
  # * pacbio_pool {V1::Pacbio::PoolResource}
  #
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

    # @!attribute [w] pacbio_pool_attributes
    # @return [Hash] attributes for creating/updating nested pacbio_pool
    attribute :pacbio_pool_attributes

    has_one :multi_pool

    # NOTE: We keep pacbio_pool and ont_pool separate because they
    # will be queried with includes that are specific to their types.
    # So using a single polymoprhic 'pool' relationship would not work
    # efficiently.
    has_one :pacbio_pool, class_name: 'Pacbio::Pool', relation_name: :pacbio_pool
    # TODO: Add ONT support
    # has_one :ont_pool, class_name: 'Ont::Pool', relation_name: :ont_pool

    def created_at
      @model.created_at.to_fs(:us)
    end

    def fetchable_fields
      super - %i[pacbio_pool_attributes]
    end

    # JSONAPI::Resources polymorphic support.
    # This gets around issues with namespaced lookups
    def self.resource_klass_for(type)
      # TODO: This wont work when we add ONT
      #
      # We need to distinguish between Pacbio::Pool and Ont::Pool types here.
      # We can either update json_api_resources to use different type names internally, add
      # more context to this override to identify both cases or retrieve ONT pools differently.
      #
      # This is a bug in JSONAPI::Resources when using namespaced polymorphic relationships
      # as both Ont::Pool and Pacbio::Pool have type 'pools'. This is due to the demodulization
      # of type and pluralization that happens internally See https://github.com/sanger/jsonapi-resources/blob/master/lib/jsonapi/basic_resource.rb#L454
      # We can work around it by explicitly checking for 'pools' and mapping it to Pacbio::Pool
      # for mvp but when we come to add ONT support we will need a better solution.
      #
      # If we don't map 'pools' here it will attempt to use V1::PoolResource which isn't backed
      # by a model and it will fail the join lookup here https://github.com/sanger/jsonapi-resources/blob/master/lib/jsonapi/active_relation/join_manager.rb#L70
      case type
      when 'pools'
        type = 'Pacbio::Pool'
      end
      super
    end
  end
end
