# frozen_string_literal: true

module V1
  module Pacbio
    # PoolResource
    class PoolResource < JSONAPI::Resource
      model_name 'Pacbio::Pool'

      has_one :tube
      has_many :libraries

      attributes :volume, :concentration, :template_prep_kit_box_barcode,
                 :insert_size, :created_at, :updated_at,
                 :library_attributes
      attribute :source_identifier, readonly: true

      def library_attributes=(library_parameters)
        @model.library_attributes = library_parameters.map do |library|
          library.permit(:id, :volume, :template_prep_kit_box_barcode,
                         :concentration, :insert_size, :pacbio_request_id, :tag_id)
        end
      end

      def fetchable_fields
        super - [:library_attributes]
      end

      def self.records_for_populate(*_args)
        super.preload(source_wells: :plate)
      end

      def created_at
        @model.created_at.to_s(:us)
      end

      def updated_at
        @model.updated_at.to_s(:us)
      end
    end
  end
end
