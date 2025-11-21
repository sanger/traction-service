# frozen_string_literal: true

module V1
  module Pacbio
    module Runs
      #
      # @note This endpoint can't be directly accessed via the `/v1/pacbio/runs/tubes/` endpoint
      # as it is only accessible via the nested route under {V1::Pacbio::Run} using includes.
      #
      class TubeResource < V1::Pacbio::TubeResource
      end
    end
  end
end
