# frozen_string_literal: true

module V1
  # @todo This documentation does not yet include a detailed description of what this resource represents.
  # @todo This documentation does not yet include detailed descriptions for relationships, attributes and filters.
  # @todo This documentation does not yet include any example usage of the API via cURL or similar.
  #
  # @note Access this resource via the `/v1/library_types` endpoint.
  #
  # Provides a JSON:API representation of {LibraryType} and exposes valid library type options
  # for use by the UI.
  #
  # For more information about JSON:API see the [JSON:API Specifications](https://jsonapi.org/format/)
  # or look at the [JSONAPI::Resources](http://jsonapi-resources.com/) package for the service
  # implementation of the JSON:API standard.
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
