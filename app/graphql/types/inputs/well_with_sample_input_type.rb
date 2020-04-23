# frozen_string_literal: true

module Types
  module Inputs
    # The input arguments for a Well containing a Sample.
    class WellWithSampleInputType < WellInputType
      argument :sample, SampleInputType, required: false
    end
  end
end
