# frozen_string_literal: true

module V1
  module Pacbio
    module Runs
      # PoolResource
      class PoolResource < JSONAPI::Resource
        model_name 'Pacbio::Pool'

        has_many :libraries
      end
    end
  end
end
