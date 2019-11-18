# frozen_string_literal: true

module V1
  module Pacbio
    # WellResource
    class WellLibraryResource < JSONAPI::Resource
      model_name 'Pacbio::WellLibrary'

      attributes :barcode
    end
  end
end
