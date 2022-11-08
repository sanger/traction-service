# frozen_string_literal: true

module V1
  module Ont
    # PlateResource
    class PlateResource < JSONAPI::Resource
      model_name '::Plate'

      attributes :barcode, :created_at

      has_many :wells

      # Filters
      filter :barcode, apply: ->(records, value, _options) { records.by_barcode(value) }

      def self.records(_options = {})
        super.by_pipeline(:ont)
      end

      def created_at
        @model.created_at.to_fs(:us)
      end
    end
  end
end
