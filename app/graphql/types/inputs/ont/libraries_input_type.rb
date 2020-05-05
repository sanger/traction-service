# frozen_string_literal: true

module Types
  module Inputs
    module Ont
      # The input arguments for Ont libraries.
      class LibrariesInputType < BaseInputObject
        argument :plate_barcode, String, required: false
        argument :tag_set_name, String, required: false
        argument :well_primary_grouping_direction, String, required: false
      end
    end
  end
end
