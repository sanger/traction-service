# frozen_string_literal: true

module V1
  #
  # @note Access this resource via the `/v1/tags` endpoint.
  #
  # Provides a JSON:API representation of {Tag}.
  #
  # For more information about JSON:API see the [JSON:API Specifications](https://jsonapi.org/format/)
  # or look at the [JSONAPI::Resources](http://jsonapi-resources.com/) package for the service
  # implementation of the JSON:API standard.
  #
  ## Primary relationships:
  # * tag_set {V1::TagSetResource} - The tag set this tag belongs to.
  #
  # @example
  #   curl -X GET http://localhost:3000/v1/tags/1
  #   curl -X GET http://localhost:3000/v1/tags/
  #   curl -X GET http://localhost:3000/v1/tags/1?include=tag_set
  #
  #   curl -X POST "http://yourdomain.com/v1/tags" \
  #     -H "accept: application/vnd.api+json" \
  #     -H "Content-Type: application/vnd.api+json" \
  #     -d '{
  #       "data": {
  #         "type": "tags",
  #         "attributes": {
  #           "oligo": "ACGTACGT",
  #           "oligo_reverse": "TGCATGCA",
  #           "group_id": 1,
  #           "tag_set_id": 1
  #         }
  #       }
  #     }'
  # curl -X PATCH "http://yourdomain.com/v1/tags/1" \
  #     -H "accept: application/vnd.api+json" \
  #     -H "Content-Type: application/vnd.api+json" \
  #     -d '{
  #       "data": {
  #         "type": "tags",
  #         "id": "1",
  #         "attributes": {
  #           "oligo": "TGCAACGT"
  #         }
  #       }
  #     }'
  #
  # @note Tags should not be destroyed via the API; use the `active` attribute on tag sets
  # to deactivate tags instead.
  class TagResource < JSONAPI::Resource
    # @!attribute [rw] oligo
    #   @return [String] the oligo sequence
    # @!attribute [rw] group_id
    #   @return [Integer] the ID of the group
    # @!attribute [rw] tag_set_id
    #   @return [Integer] the ID of the tag set
    attributes :oligo, :oligo_reverse, :group_id, :tag_set_id

    # originally put 'belongs_to' to match the model, but got following warning from jsonapi:
    # ...you exposed a `has_one` relationship  using the `belongs_to` class method...
    # We think `has_one` is more appropriate... etc.
    has_one :tag_set
  end
end
