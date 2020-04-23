# frozen_string_literal: true

module Types
  module Inputs
    # The input arguments for a Sample.
    class SampleInputType < BaseInputObject
      argument :name, String, required: false
    end
  end
end
