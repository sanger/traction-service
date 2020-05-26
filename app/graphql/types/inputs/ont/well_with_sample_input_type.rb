# frozen_string_literal: true

module Types
  module Inputs
    module Ont
      # The input arguments for a Well containing Samples.
      class WellWithSampleInputType < WellInputType
        argument :sample, SampleInputType, 'The sample contained in the well.', required: false
      end
    end
  end
end
