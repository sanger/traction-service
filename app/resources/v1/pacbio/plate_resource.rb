# frozen_string_literal: true

module V1
  module Pacbio
    # PlateResource
    class PlateResource < JSONAPI::Resource
      model_name '::Plate'

      attributes :barcode

      has_many :wells

      def self.records(_options = {})
        ::Plate.by_pipeline(:pacbio)
      end
    end
  end
end
