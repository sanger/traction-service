# frozen_string_literal: true

module V1
  module Pacbio
    # AliquotResource
    class AliquotResource < V1::AliquotResource
      include Shared::RunSuitability

      # We could move this to a concern and dynamically build the polymorphic types
      # but no need to do this unless we use this for any other pipelines
      # for now this is best in here as it is specific to pacbio
      POLYMORPHIC_TYPES = %w[pacbio/requests pacbio/pools pacbio/libraries].freeze

      has_one :source, polymorphic: true, polymorphic_types: POLYMORPHIC_TYPES
      has_one :used_by, polymorphic: true, polymorphic_types: POLYMORPHIC_TYPES

      # Required to get around polymorphism when trying to access nested includes data
      # e.g. aliquot.source.x becomes aliquot.request.x, aliquot.pool.x, aliquot.library.x etc
      has_one :request, class_name: 'Request', relation_name: :request
      has_one :pool, class_name: 'Pool', relation_name: :pool
      has_one :library, class_name: 'Library', relation_name: :library

      #  # Aliquot polymorphism support
      # # This fixes the polymorphic relationships in json-api resources
      # # as json-api resources underscores and pluralizes the type
      def self.resource_klass_for(type)
        super(type.underscore.pluralize.gsub('pacbio/', ''))
      end
    end
  end
end
