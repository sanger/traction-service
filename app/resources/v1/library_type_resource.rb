# frozen_string_literal: true

module V1
  #
  # @note Access this resource via the `/v1/library_types` endpoint.
  #
  # Provides a JSON:API representation of {LibraryType} and exposes valid library type options
  # for use by the UI.
  #
  # For more information about JSON:API see the [JSON:API Specifications](https://jsonapi.org/format/)
  # or look at the [JSONAPI::Resources](http://jsonapi-resources.com/) package for the service
  # implementation of the JSON:API standard.
  #
  ## Filters:
  # * pipeline
  # * active
  #
  # @example
  #   curl -X GET http://localhost:3100/v1/library_types/1
  #   curl -X GET http://localhost:3100/v1/library_types/
  #   curl -X GET "http://localhost:3100/v1/library_types?filter[pipeline]=ont"
  #   curl -X GET "http://localhost:3100/v1/library_types?filter[active]=true"
  #
  # curl -X POST "http://localhost:3100/v1/library_types" \
  #     -H "accept: application/vnd.api+json" \
  #     -H "Content-Type: application/vnd.api+json" \
  #     -d '{
  #       "data": {
  #         "type": "library_types",
  #         "attributes": {
  #           "name": "New Library Type",
  #           "pipeline": "ont",
  #           "external_identifier": "EXT123",
  #           "active": true
  #         }
  #       }
  #     }'
  #
  # curl -X PATCH "http://localhost:3100/v1/library_types/1" \
  #     -H "accept: application/vnd.api+json" \
  #     -H "Content-Type: application/vnd.api+json" \
  #     -d '{
  #       "data": {
  #         "type": "library_types",
  #         "id": "1",
  #         "attributes": {
  #           "name": "Updated Library Type Name"
  #         }
  #       }
  #     }'
  #
  class LibraryTypeResource < JSONAPI::Resource
    # @!attribute [rw] name
    #   @return [String] the name of the library type
    # @!attribute [rw] pipeline
    #   @return [String] the pipeline associated with the library type
    # @!attribute [rw] created_at
    #   @return [String] the timestamp when the library type was created
    # @!attribute [rw] updated_at
    #   @return [String] the timestamp when the library type was last updated
    # @!attribute [rw] external_identifier
    #   @return [String] the external identifier of the library type
    # @!attribute [rw] active
    #   @return [Boolean] the active status of the library type
    attributes :name, :pipeline, :created_at, :updated_at, :external_identifier, :active

    filter :pipeline
    filter :active, default: true
  end
end
