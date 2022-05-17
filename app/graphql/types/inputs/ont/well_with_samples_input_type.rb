# frozen_string_literal: true

module Types
  module Inputs
    module Ont
      # The input arguments for a Well containing Samples.
      class WellWithSamplesInputType < WellInputType
        argument :samples, [SampleInputType], 'Samples contained in the well.', required: false
      end
    end
  end
end
