# frozen_string_literal: true

module Types
  module Inputs
    # The input arguments for a Plate with accompanying Samples.
    class PlateWithSamplesInputType < PlateInputType
      argument :wells, [WellWithSampleInputType], required: true
    end
  end
end
