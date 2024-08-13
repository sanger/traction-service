# frozen_string_literal: true

module V1
  module Pacbio
    # @todo This documentation does not yet include a detailed description of what this resource represents.
    # @todo This documentation does not yet include detailed descriptions for relationships, attributes and filters.
    # @todo This documentation does not yet include any example usage of the API via cURL or similar.
    #
    # @note Access this resource via the `/api/v1/pacbio/aliquot/` endpoint.
    #
    # Provides a JSON:API representation of {Aliquot}.
    #
    # For more information about JSON:API see the [JSON:API Specifications](https://jsonapi.org/format/)
    # or look at the [JSONAPI::Resources](http://jsonapi-resources.com/) package
    # for the service implementation of the JSON:API standard.
    class AliquotResource < V1::AliquotResource
      include Shared::RunSuitability

      # We could move this to a concern and dynamically build the polymorphic types
      # but no need to do this unless we use this for any other pipelines
      # for now this is best in here as it is specific to pacbio
      POLYMORPHIC_TYPES = %w[pacbio/requests pacbio/pools pacbio/libraries].freeze

      # @!attribute [rw] source
      #   @return [Object] the source of the aliquot, can be a request, pool, or library
      # @!attribute [rw] used_by
      #   @return [Object] the entity that used the aliquot, can be a request, pool, or library
      # @!attribute [rw] request
      #   @return [Request] the request associated with the aliquot
      # @!attribute [rw] pool
      #   @return [Pool] the pool associated with the aliquot
      # @!attribute [rw] library
      #   @return [Library] the library associated with the aliquot
      has_one :source, polymorphic: true, polymorphic_types: POLYMORPHIC_TYPES
      has_one :used_by, polymorphic: true, polymorphic_types: POLYMORPHIC_TYPES

      # Required to get around polymorphism when trying to access nested includes data
      # e.g. aliquot.source.x becomes aliquot.request.x, aliquot.pool.x, aliquot.library.x etc
      has_one :request, class_name: 'Request', relation_name: :request
      has_one :pool, class_name: 'Pool', relation_name: :pool
      has_one :library, class_name: 'Library', relation_name: :library

      # Aliquot polymorphism support.
      # This fixes the polymorphic relationships in json-api resources
      #  as json-api resources underscores and pluralizes the type
      def self.resource_klass_for(type)
        super(type.underscore.pluralize.gsub('pacbio/', ''))
      end
    end
  end
end
