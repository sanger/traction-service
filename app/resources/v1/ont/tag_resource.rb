# frozen_string_literal: true

module V1
  module Ont
    # @todo This documentation does not yet include a detailed description of what this resource represents.
    # @todo This documentation does not yet include detailed descriptions for relationships, attributes and filters.
    # @todo This documentation does not yet include any example usage of the API via cURL or similar.
    #
    # @note Access this resource via the `/v1/ont/tag/` endpoint.
    #
    # Provides a JSON:API representation of {Ont::Tag}. This is a resource to return all of the ONT
    #  tags.
    #
    # For more information about JSON:API see the [JSON:API Specifications](https://jsonapi.org/format/)
    # or look at the [JSONAPI::Resources](http://jsonapi-resources.com/) package
    # for the service implementation of the JSON:API standard.
    class TagResource < JSONAPI::Resource
      model_name 'Tag'

      # @!attribute [rw] oligo
      #   @return [String] the oligo sequence of the tag
      # @!attribute [rw] group_id
      #   @return [Integer] the group identifier for the tag
      attributes :oligo, :group_id

      has_one :tag_set
    end
  end
end
