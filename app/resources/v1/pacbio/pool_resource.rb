# frozen_string_literal: true

module V1
  module Pacbio
    # PoolResource
    class PoolResource < JSONAPI::Resource
      model_name 'Pacbio::Pool'

      has_one :tube
      has_many :libraries

      attributes :volume, :concentration, :template_prep_kit_box_barcode,
                 :fragment_size, :source_identifier, :created_at, :updated_at

      attribute :libraries, delegate: :libraries

      def libraries=(library_parameters)
        @model.libraries = library_parameters.map do |library|
          library.permit(:volume, :template_prep_kit_box_barcode,
                         :concentration, :fragment_size, :pacbio_request_id, :tag_id)
        end
      end

      def fetchable_fields
        super - [:libraries]
      end

      def self.records_for_populate(*_args)
        super.preload(:source_wells)
      end

      def self.create_model(*_opt)
        ::Pacbio::PoolCreator.new
      end
    end
  end
end
