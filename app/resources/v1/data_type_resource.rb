# frozen_string_literal: true

module V1
  #
  # @note Access this resource via the `/v1/data_types` endpoint.
  #
  # Provides a JSON:API representation of {DataType} and exposes valid data type options
  # for use by the UI.
  #
  # For more information about JSON:API see the [JSON:API Specifications](https://jsonapi.org/format/)
  # or look at the [JSONAPI::Resources](http://jsonapi-resources.com/) package for the service
  # implementation of the JSON:API standard.
  #
  ## Filters:
  # * pipeline
  #
  # @example
  #   curl -X GET http://localhost:3000/v1/data_types/1
  #   curl -X GET http://localhost:3000/v1/data_types/
  #   curl -X GET "http://localhost:3000/v1/data_types?filter[pipeline]=ont"
  #
  # curl -X POST "http://yourdomain.com/v1/data_types" \
  #     -H "accept: application/vnd.api+json" \
  #     -H "Content-Type: application/vnd.api+json" \
  #     -d '{
  #       "data": {
  #         "type": "data_types",
  #         "attributes": {
  #           "name": "New Data Type",
  #           "pipeline": "ont"
  #         }
  #       }
  #     }'
  #
  # curl -X PATCH "http://yourdomain.com/v1/data_types/1" \
  #     -H "accept: application/vnd.api+json" \
  #     -H "Content-Type: application/vnd.api+json" \
  #     -d '{
  #       "data": {
  #         "type": "data_types",
  #         "id": "1",
  #         "attributes": {
  #           "name": "Updated Data Type Name"
  #         }
  #       }
  #     }'
  #
  class DataTypeResource < JSONAPI::Resource
    # @!attribute [rw] name
    #   @return [String] the name of the data type
    # @!attribute [rw] pipeline
    #   @return [String] the pipeline associated with the data type
    # @!attribute [rw] created_at
    #   @return [String] the timestamp when the data type was created
    # @!attribute [rw] updated_at
    #   @return [String] the timestamp when the data type was last updated
    attributes :name, :pipeline, :created_at, :updated_at

    filter :pipeline
  end
end
