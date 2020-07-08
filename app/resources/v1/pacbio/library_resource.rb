# frozen_string_literal: true

module V1
  module Pacbio
    # LibraryResource
    class LibraryResource < JSONAPI::Resource
      model_name 'Pacbio::Library'

      attributes :state, :barcode, :volume, :concentration, :template_prep_kit_box_barcode, :fragment_size,
                 :created_at, :deactivated_at, :sample_names

      has_many :requests, class_name: 'RequestLibrary', relation_name: :request_libraries
      has_one :tube

      def barcode
        @model.tube&.barcode
      end

      def created_at
        @model.created_at.to_s(:us)
      end

      def deactivated_at
        @model&.deactivated_at&.to_s(:us)
      end
    end
  end
end
