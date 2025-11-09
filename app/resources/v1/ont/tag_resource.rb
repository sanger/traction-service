# frozen_string_literal: true

module V1
  module Ont
    # Provides a JSON:API representation of {Ont::Tag} model.
    #
    # A tag is a short unique DNA sequence (oligo) in a tag set (barcode set).
    # A tag set can have a single group of tags or multiple groups of tags
    # (indexes). A tag can only belong to one group within a tag set.
    #
    # @note Access to this resource is disabled. See
    # @note Access this resource via the `/v1/ont/tags/` endpoint.
    # @todo This documentation does not yet include any example usage of the API via cURL or similar.
    #
    # @note Access this resource via the `/v1/ont/tags/` endpoint.
    #
    # Provides a JSON:API representation of {Tag}. This is a resource to return all of the ONT
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
