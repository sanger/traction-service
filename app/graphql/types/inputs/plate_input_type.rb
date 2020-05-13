# frozen_string_literal: true

module Types
  module Inputs
    # The input arguments for a Plate.
    class PlateInputType < BaseInputObject
      argument :barcode, String,
               'The barcode of the plate.  If not specified, a barcode will be generated.',
               required: false
    end
  end
end
