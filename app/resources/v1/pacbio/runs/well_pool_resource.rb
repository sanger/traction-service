# frozen_string_literal: true

module V1
  module Pacbio
    module Runs
      # WellPoolResource
      class WellPoolResource < JSONAPI::Resource
        model_name 'Pacbio::WellPool'

        has_one :pool
      end
    end
  end
end
