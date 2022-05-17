# frozen_string_literal: true

module V1
  module Saphyr
    # RequestResource
    class RequestResource < JSONAPI::Resource
      model_name 'Saphyr::Request', add_model_hint: false

      attributes(*::Saphyr.request_attributes, :sample_name, :barcode,
                 :sample_species, :created_at, :source_identifier)

      def barcode
        @model&.tube&.barcode
      end

      def created_at
        @model.created_at.to_fs(:us)
      end
    end
  end
end
