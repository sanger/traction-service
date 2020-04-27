# frozen_string_literal: true

module Types
  module Inputs
    # The input arguments for a Well.
    class WellInputType < BaseInputObject
      argument :position, String, required: false
    end
  end
end
