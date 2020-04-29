# frozen_string_literal: true

module Types
  module Inputs
    # The input arguments for a Library.
    class LibraryInputType < BaseInputObject
      argument :plate_id, Int, required: false
    end
  end
end
