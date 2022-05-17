# frozen_string_literal: true

module Types
  module Inputs
    module Ont
      # The input arguments for Ont libraries.
      class LibraryCreationArgumentsInputType < BaseInputObject
        argument :plate_barcode, String, 'The barcode of the plate to create libraries from.',
                 required: false
      end
    end
  end
end
