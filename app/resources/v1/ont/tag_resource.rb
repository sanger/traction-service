# frozen_string_literal: true

module V1
  module Ont
    # Provides a JSON:API representation of {Ont::Tag}.
    #
    # A tag is a short unique DNA sequence (oligo) in a tag set (barcode set).
    # A tag set can have a single group of tags or multiple groups of tags
    # (indexes). A tag can only belong to one group within a tag set.
    #
    ## Primary relationships:
    # * tagset {V1::Ont::TagSetResource} - The tag set to which the tag belongs.
    #
    # @note Access this resource via the `/v1/ont/tags/` endpoint.
    #
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
