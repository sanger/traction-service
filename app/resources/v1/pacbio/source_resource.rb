# frozen_string_literal: true

module V1
  module Pacbio
    # Provides a JSON:API representation of source for {Pacbio::Aliquot}.
    #
    # This resource represents the polymorphic source of a Pacbio aliquot, which
    # can be a request, pool, or library.
    #
    # @todo This documentation does not yet include detailed descriptions for relationships, attributes and filters.
    # @todo This documentation does not yet include any example usage of the API via cURL or similar.
    #
    # @note Access this resource via the `/v1/pacbio/sources/` endpoint.
    #
    class SourceResource < V1::SourceResource
    end
  end
end
