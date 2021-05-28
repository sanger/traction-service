# frozen_string_literal: true

module V1
  module Pacbio
    module Runs
      # WellLibraryResource
      class WellLibraryResource < JSONAPI::Resource
        model_name 'Pacbio::WellLibrary'

        attributes :barcode
      end
    end
  end
end
