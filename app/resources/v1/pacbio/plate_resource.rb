# frozen_string_literal: true

module V1
  module Pacbio
    # PlateResource
    class PlateResource < JSONAPI::Resource
      model_name '::Plate'

      attributes :barcode, :created_at

      has_many :wells

      # Filters
      filter :barcode, apply: ->(records, value, _options) { records.by_barcode(value) }

      def self.records(_options = {})
        super.by_pipeline(:pacbio)
      end

      def created_at
        @model.created_at.to_s(:us)
      end
    end
  end
end
