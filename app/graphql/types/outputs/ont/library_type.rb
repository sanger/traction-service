# frozen_string_literal: true

module Types
  module Outputs
    module Ont
      # The type for Ont::Library objects.
      class LibraryType < CommonOutputObject
        field :name, String, 'The name of this library.', null: false
        field :plate_barcode, String, 'The barcode of the plate this library was created from.',
              null: false
        field :pool, Integer,
              'An index of the group of wells combined from the plate to form this library.',
              null: false
        field :pool_size, Integer, 'The number of samples contained in this library.', null: false
        field :tube_barcode, String, 'The barcode of the tube this library is contained in.',
              null: true
        field :assigned_to_flowcell, Boolean,
              'The value of whether this library is being used in a run.',
              null: false
      end
    end
  end
end
