# frozen_string_literal: true

module V1
  module Pacbio
    # PlateResource
    class PlateResource < JSONAPI::Resource
      model_name '::Plate'

      attributes :barcode, :created_at

      has_many :wells

      paginator :paged

      def self.default_sort
        [{ field: 'created_at', direction: :desc }]
      end

      filter :barcode

      def self.records(_options = {})
        super.by_pipeline(:pacbio)
      end

      def created_at
        @model.created_at.to_fs(:us)
      end
    end
  end
end
