# frozen_string_literal: true

module V1
  # TagResource
  module Pacbio
    module Runs
      #
      # @note This endpoint can't be directly accessed via the `/v1/pacbio/runs/tags/` endpoint
      # as it is only accessible via the nested route under {V1::Pacbio::Run} using includes.
      #
      class TagResource < V1::Pacbio::TagResource
      end
    end
  end
end
