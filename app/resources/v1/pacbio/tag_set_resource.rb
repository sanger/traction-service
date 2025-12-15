# frozen_string_literal: true

module V1
  module Pacbio
    # Provides a JSON:API representation of {TagSet}.
    #
    ## Filters:
    # * pipeline - pipeline name (default: pacbio)
    # * name - tag set name
    #
    # @note Access this resource via the `/v1/pacbio/tag_sets/` endpoint.
    #
    # @example
    #   curl -X GET http://localhost:3100/v1/pacbio/tag_sets/1
    #   curl -X GET http://localhost:3100/v1/pacbio/tag_sets/
    #
    #   curl -X GET http://localhost:3100/v1/pacbio/tag_sets?filter[name]=tag_set_name
    #   curl -X GET http://localhost:3100/v1/pacbio/tag_sets?filter[pipeline]=pacbio&include=tags
    #
    #  curl -X POST http://localhost:3100/v1/pacbio/tag_sets \
    #   -H "Content-Type: application/vnd.api+json" \
    #   -H "Accept: application/vnd.api+json" \
    #       -d '{
    #             "data": {
    #               "type": "tag_sets",
    #               "attributes": {
    #                 "name": "New Tag Set",
    #                 "description": "A description of the new tag set"
    #               }
    #             }
    #           }'
    #
    # @note Tag sets should not be destroy via the API; use the `active` attribute to
    # deactivate tag sets instead.
    # This is a soft delete; the record will be marked as inactive
    # but not removed from the database.
    # The current way of creating tag sets is internally this should be disabled.
    class TagSetResource < V1::TagSetResource
      filter :pipeline, default: :pacbio

      # Ensure that any tag sets created via this endpoint are scoped to the
      # pacbio pipeline
      def self.create_model
        _model_class.pacbio_pipeline.new
      end

      filter :name
    end
  end
end
