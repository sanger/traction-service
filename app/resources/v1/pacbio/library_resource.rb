# frozen_string_literal: true

module V1
  module Pacbio
    # LibraryResource
    class LibraryResource < JSONAPI::Resource
      model_name 'Pacbio::Library'

      attributes :volume, :concentration, :library_kit_barcode, :fragment_size,
                 :pacbio_tag_id, :pacbio_request_id, :uuid, :barcode

      def barcode
        @model.tube&.barcode
      end
    end
  end
end
