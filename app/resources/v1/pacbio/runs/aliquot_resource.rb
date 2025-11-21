# frozen_string_literal: true

module V1
  module Pacbio
    module Runs
      # Provides a JSON:API resource of {Aliquot}.
      #
      # @note Access this resource via the `/v1/pacbio/runs/aliquots` endpoint.
      #
      # @example
      #
      #   curl -X GET "http://localhost:3100/v1/pacbio/runs/1?include=plates.wells.used_aliquots"
      #
      class AliquotResource < V1::Pacbio::AliquotResource
      end
    end
  end
end
