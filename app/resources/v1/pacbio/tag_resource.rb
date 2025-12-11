# frozen_string_literal: true

module V1
  module Pacbio
    # Provides a JSON:API representation of {Tag}.
    #
    ## Primary relationships:
    # * tag_set {V1::Ont::TagSetResource} - The associated tag set
    # @note Access this resource via the `/v1/pacbio/tags/` endpoint.
    #
    # Returns the available tags for Pacbio
    #
    # For more information about JSON:API see the [JSON:API Specifications](https://jsonapi.org/format/)
    # or look at the [JSONAPI::Resources](http://jsonapi-resources.com/) package
    # for the service implementation of the JSON:API standard.
    class TagResource < JSONAPI::Resource
      model_name 'Tag'

      # @!attribute [rw] oligo
      #   @return [String] the oligo of the tag
      # @!attribute [rw] group_id
      #   @return [Integer] the group ID of the tag
      attributes :oligo, :oligo_reverse, :group_id

      # originally put 'belongs_to' to match the model, but got following warning from jsonapi:
      # ...you exposed a `has_one` relationship  using the `belongs_to` class method...
      # We think `has_one` is more appropriate... etc.
      has_one :tag_set
    end
  end
end
