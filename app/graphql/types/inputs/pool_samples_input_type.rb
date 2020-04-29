# frozen_string_literal: true

module Types
  module Inputs
    # The input arguments required to pool samples.
    class PoolSamplesInputType < BaseInputObject
      argument :plate_id, Int, required: true
      argument :tag_set, Int, required: true # 24 or 96
    end
  end
end
