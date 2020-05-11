# frozen_string_literal: true

module Types
  module Inputs
    module Ont
      # The input arguments for Ont libraries.
      class LibraryCreationArgumentsInputType < BaseInputObject
        argument :plate_barcode, String, required: false
      end
    end
  end
end
