# frozen_string_literal: true

module V1
  module Ont
    # Provides a JSON:API representation of {Ont::Tag}.
    #
    # @note This resource cannot be accessed via the `/v1/ont/tags/` endpoint.
    # It is only accessible via the nested route under {Ont::TagSet} using includes.
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
