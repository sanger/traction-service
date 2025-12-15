# frozen_string_literal: true

module V1
  module Pacbio
    # Provides a JSON:API representation of source for {Pacbio::Aliquot}.
    #
    # This resource represents the polymorphic source of a Pacbio aliquot, which
    # can be a request, pool, or library.
    #
    # @note This endpoint can't be directly accessed via the `/v1/pacbio/sources/` endpoint
    # as it is only accessible via the nested route under {V1::Pacbio::Aliquot} using includes.
    #
    class SourceResource < V1::SourceResource
    end
  end
end
