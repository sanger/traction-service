# frozen_string_literal: true

module V1
  #
  # @note Access this resource via the `/v1/pacbio/tag_sets/` endpoint.
  #
  # Provides a JSON:API representation of {TagSet}.
  #
  # For more information about JSON:API see the [JSON:API Specifications](https://jsonapi.org/format/)
  # or look at the [JSONAPI::Resources](http://jsonapi-resources.com/) package
  # for the service implementation of the JSON:API standard.
  #
  # filters:
  #
  # - pipeline
  #
  # @example
  #   curl -X GET http://localhost:3000/v1/pacbio/tag_sets/1
  #   curl -X GET http://localhost:3000/v1/pacbio/tag_sets?include=tags
  #   curl -X GET http://localhost:3000/v1/pacbio/tag_sets/
  #   curl -X GET "http://localhost:3000/v1/pacbio/tag_sets?filter[pipeline]=pacbio"
  #
  #  curl -X POST "http://yourdomain.com/v1/pacbio/tag_sets" \
  #      -H "accept: application/vnd.api+json" \
  #      -H "Content-Type: application/vnd.api+json" \
  #      -d '{
  #        "data": {
  #          "type": "tag_sets",
  #          "attributes": {
  #            "name": "New Tag Set",
  #            "pipeline": "pacbio"
  #          }
  #        }
  #      }'
  #
  # curl -X PATCH "http://yourdomain.com/v1/pacbio/tag_sets/1" \
  #      -H "accept: application/vnd.api+json" \
  #      -H "Content-Type: application/vnd.api+json" \
  #      -d '{
  #        "data": {
  #          "type": "tag_sets",
  #          "id": "1",
  #          "attributes": {
  #            "name": "Updated Tag Set Name"
  #          }
  #        }
  #      }'
  #
  # @note Tag sets should not be destroy via the API; use the `active` attribute to
  # deactivate tag sets instead.
  # This is a soft delete; the record will be marked as inactive but not removed from the database.
  #
  # curl -X PATCH "http://yourdomain.com/v1/pacbio/tag_sets/1" \
  #      -H "accept: application/vnd.api+json" \
  #      -H "Content-Type: application/vnd.api+json" \
  #      -d '{
  #        "data": {
  #          "type": "tag_sets",
  #          "id": "1",
  #          "attributes": {
  #            "active": false
  #          }
  #        }
  #      }'
  #
  class TagSetResource < JSONAPI::Resource
    # @!attribute [rw] name
    #   @return [String] the name of the tag set
    # @!attribute [rw] uuid
    #   @return [String] the UUID of the tag set
    # @!attribute [rw] pipeline
    #   @return [String] the pipeline associated with the tag set
    attributes :name, :uuid, :pipeline

    has_many :tags

    filter :pipeline

    def self.records(options = {})
      super.where(active: true)
    end
  end
end
