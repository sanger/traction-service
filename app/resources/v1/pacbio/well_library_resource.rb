# frozen_string_literal: true

module V1
  module Pacbio
    # WellResource
    class WellLibraryResource < JSONAPI::Resource
      model_name 'Pacbio::WellLibrary'

      attributes  :volume, :concentration, :library_kit_barcode, :fragment_size,
                  :sample_names
    end
  end
end
