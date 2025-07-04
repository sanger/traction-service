# frozen_string_literal: true

module V1
  # @todo This documentation does not yet include a detailed description of what this resource represents.
  # @todo This documentation does not yet include detailed descriptions for relationships, attributes and filters.
  # @todo This documentation does not yet include any example usage of the API via cURL or similar.
  #
  # @note Access this resource via the `/v1/tags` endpoint.
  #
  # Provides a JSON:API representation of {Tag}.
  #
  # For more information about JSON:API see the [JSON:API Specifications](https://jsonapi.org/format/)
  # or look at the [JSONAPI::Resources](http://jsonapi-resources.com/) package for the service
  # implementation of the JSON:API standard.
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
