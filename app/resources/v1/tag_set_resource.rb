# frozen_string_literal: true

module V1
  # @todo This documentation does not yet include a detailed description of what this resource represents.
  # @todo This documentation does not yet include detailed descriptions for relationships, attributes and filters.
  # @todo This documentation does not yet include any example usage of the API via cURL or similar.
  #
  # @note Access this resource via the `/api/v1/tag_set` endpoint.
  #
  # Provides a JSON:API representation of {TagSet}.
  #
  # For more information about JSON:API see the [JSON:API Specifications](https://jsonapi.org/format/)
  # or look at the [JSONAPI::Resources](http://jsonapi-resources.com/) package for the service
  # implementation of the JSON:API standard.
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
