# frozen_string_literal: true

module V1
  module Pacbio
    # LibraryResource
    class LibraryResource < JSONAPI::Resource
      model_name 'Pacbio::Library'

      attributes :volume, :concentration, :library_kit_barcode, :fragment_size
    end
  end
end
