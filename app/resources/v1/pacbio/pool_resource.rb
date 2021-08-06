# frozen_string_literal: true

module V1
  module Pacbio
    # PoolResource
    class PoolResource < JSONAPI::Resource
      model_name 'Pacbio::Pool'
      # before_update :wrap_model

      has_one :tube
      has_many :libraries

      attributes :volume, :concentration, :template_prep_kit_box_barcode,
                 :fragment_size, :created_at, :updated_at,
                 :library_attributes
      attribute :source_identifier, readonly: true

      def library_attributes=(library_parameters)
        @model.library_attributes = library_parameters.map do |library|
          library.permit(:id, :volume, :template_prep_kit_box_barcode,
                         :concentration, :fragment_size, :pacbio_request_id, :tag_id)
        end
      end

      def fetchable_fields
        super - [:library_attributes]
      end

      def self.records_for_populate(*_args)
        super.preload(source_wells: :plate)
      end

      # def self.create_model(*_opt)
      #   ::Pacbio::PoolCreator.new
      # end

      # def wrap_model
      #   @model = ::Pacbio::PoolUpdater.new(@model)
      # end
    end
  end
end
