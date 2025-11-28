# frozen_string_literal: true

module V1
  module Pacbio
    module Runs
      #
      # @note This endpoint can't be directly accessed via the `/v1/pacbio/runs/aliquots/` endpoint
      # as it is only accessible via the nested route under {V1::Pacbio::Run} using includes.
      #
      class AliquotResource < V1::Pacbio::AliquotResource
      end
    end
  end
end
