# frozen_string_literal: true

module V1
  # RequestResource
  module Pacbio
    module Runs
      #
      # @note This endpoint can't be directly accessed via the `/v1/pacbio/runs/requests/` endpoint
      # as it is only accessible via the nested route under {V1::Pacbio::Run} using includes.
      #
      class RequestResource < V1::Pacbio::RequestResource
      end
    end
  end
end
