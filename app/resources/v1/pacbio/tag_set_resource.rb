# frozen_string_literal: true

module V1
  module Pacbio
    # @todo This documentation does not yet include a detailed description of what this resource represents.
    # @todo This documentation does not yet include detailed descriptions for relationships, attributes and filters.
    # @todo This documentation does not yet include any example usage of the API via cURL or similar.
    #
    # @note Access this resource via the `/api/v1/pacbio/tag_set/` endpoint.
    #
    # Provides a JSON:API representation of {TagSet}.
    #
    # For more information about JSON:API see the [JSON:API Specifications](https://jsonapi.org/format/)
    # or look at the [JSONAPI::Resources](http://jsonapi-resources.com/) package
    # for the service implementation of the JSON:API standard.
    class TagSetResource < V1::TagSetResource
      filter :pipeline, default: :pacbio

      # Ensure that any tag sets created via this endpoint are scoped to the
      # pacbio pipeline
      def self.create_model
        _model_class.pacbio_pipeline.new
      end
    end
  end
end
