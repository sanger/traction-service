# frozen_string_literal: true

module V1
  module Pacbio
    # LibraryResource
    class LibraryResource < JSONAPI::Resource
      model_name 'Pacbio::Library'

      attributes :volume, :concentration, :library_kit_barcode, :fragment_size

      has_many :requests, class_name: 'RequestLibrary', relation_name: :request_libraries

      def barcode
        @model.tube&.barcode
      end
    end
  end
end
