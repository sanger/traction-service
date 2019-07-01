# frozen_string_literal: true

module V1
  module Saphyr
    # LibraryResource
    class LibraryResource < JSONAPI::Resource
      model_name 'Saphyr::Library'

      attributes :state, :barcode, :sample_name, :enzyme_name, :created_at, :deactivated_at
      has_one :sample
      has_one :tube

      def barcode
        @model.tube&.barcode
      end

      def sample_name
        @model.sample&.name
      end

      def enzyme_name
        @model.enzyme&.name
      end

      def created_at
        @model.created_at.strftime('%m/%d/%Y %I:%M')
      end

      def deactivated_at
        @model&.deactivated_at&.strftime('%m/%d/%Y %I:%M')
      end

      def self.records(_options = {})
        ::Saphyr::Library.active
      end
    end
  end
end
