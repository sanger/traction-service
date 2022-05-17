# frozen_string_literal: true

module Types
  module Inputs
    # The input arguments for a Well.
    class WellInputType < BaseInputObject
      argument :position, String,
               'The description of the position of the well.  Typically A1 through to H12.',
               required: false
    end
  end
end
