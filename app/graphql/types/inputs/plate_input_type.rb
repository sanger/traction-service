# frozen_string_literal: true

module Types
  module Inputs
    # The input arguments for a Plate.
    class PlateInputType < BaseInputObject
      argument :barcode, String, required: false
    end
  end
end
