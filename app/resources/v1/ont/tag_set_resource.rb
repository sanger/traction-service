# frozen_string_literal: true

module V1
  module Ont
    # Provides a JSON:API representation of {Ont::TagSet} model.
    #
    ## Primary relationships:
    # * tags {V1::Ont::TagResource} - The tags contained in the tag set.
    #
    # @note Access this resource via the `/v1/ont/tag_sets/` endpoint.
    #
    # @example
    #   curl -X GET http://localhost:3100/v1/ont/tag_sets
    #   curl -X GET "http://localhost:3100/v1/ont/tag_sets/1"
    #
    #   curl -X POST http://localhost:3100/v1/ont/tag_sets \
    #     -H "Content-Type: application/vnd.api+json" \
    #     -H "Accept: application/vnd.api+json" \
    #       -d '{
    #         "data": {
    #           "type": "tag_sets",
    #           "attributes": {
    #             "name": "New Tag Set"
    #            }
    #          }
    #        }'
    #
    #   curl -X PATCH http://localhost:3100/v1/ont/tag_sets/16 \
    #     -H "Content-Type: application/vnd.api+json" \
    #     -H "Accept: application/vnd.api+json" \
    #     -d '{
    #       "data": {
    #         "type": "tag_sets",
    #         "id": "16",
    #         "attributes": {
    #           "name": "Updated Tag Set Name"
    #         }
    #       }
    #     }'
    #
    class TagSetResource < V1::TagSetResource
      filter :pipeline, default: :ont

      # Ensure that any tag sets created via this endpoint are scoped to the
      # ont pipeline
      def self.create_model
        _model_class.ont_pipeline.new
      end
    end
  end
end
