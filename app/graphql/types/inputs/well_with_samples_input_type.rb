# frozen_string_literal: true

module Types
  module Inputs
    # The input arguments for a Well containing Samples.
    class WellWithSamplesInputType < WellInputType
      argument :samples, [SampleInputType], required: false
    end
  end
end
