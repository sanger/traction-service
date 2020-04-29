# frozen_string_literal: true

module Types
  module Inputs
    # The input arguments required to pool samples.
    class PoolSamplesInputType < BaseInputObject
      argument :plate_id, Int, required: false
      # Add tag set argument
    end
  end
end
