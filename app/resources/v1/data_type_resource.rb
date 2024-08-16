# frozen_string_literal: true

module V1
  # @todo This documentation does not yet include a detailed description of what this resource represents.
  # @todo This documentation does not yet include detailed descriptions for relationships, attributes and filters.
  # @todo This documentation does not yet include any example usage of the API via cURL or similar.
  #
  # @note Access this resource via the `/v1/data_types` endpoint.
  #
  # Provides a JSON:API representation of {DataType} and exposes valid data type options
  # for use by the UI.
  #
  # For more information about JSON:API see the [JSON:API Specifications](https://jsonapi.org/format/)
  # or look at the [JSONAPI::Resources](http://jsonapi-resources.com/) package for the service
  # implementation of the JSON:API standard.
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
