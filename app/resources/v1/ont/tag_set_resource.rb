# frozen_string_literal: true

module V1
  module Ont
    # Provides a JSON:API representation of {Ont::TagSet} model.
    #
    # A tag set is a collection of unique oligo sequences known as tags or
    # barcodes that are ligated to DNA or RNA samples during libray preparation
    # to enable multiplexing, allowing multiple samples to be sequenced
    # simultaneously on a single flowcell.
    #
    ## Primary relationships:
    # * tags {V1::Ont::TagResource} - The tags contained in the tag set.
    #
    # @note Access this resource via the `/v1/ont/tag_sets/` endpoint.
    #
    # @example GET request to list all ONT tag sets
    #   curl -X GET http://localhost:3100/v1/ont/tag_sets
    #
    # @example GET request to retrieve a specific ONT tag set by ID
    #  curl -X GET "http://localhost:3100/v1/ont/tag_sets/1"
    #
    # @example POST request to create a new ONT tag set
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
    # @example PATCH request to update an existing ONT tag set with name change
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
    # @example DELETE request to remove an existing ONT tag set
    #   curl -X DELETE http://localhost:3100/v1/ont/tag_sets/16
    #
    # For more information about JSON:API see the [JSON:API Specifications](https://jsonapi.org/format/)
    # or look at the [JSONAPI::Resources](http://jsonapi-resources.com/) package
    # for the service implementation of the JSON:API standard.
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
