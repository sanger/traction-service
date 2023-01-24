# frozen_string_literal: true

module V1
  module Pacbio
    # PoolResource
    class PoolResource < JSONAPI::Resource
      include Shared::RunSuitability

      model_name 'Pacbio::Pool'

      # If we don't specify the relation_name here, jsonapi-resources
      # attempts to use_related_resource_records_for_joins
      # In this case I can see it using container_associations
      # so seems to be linking the wrong tube relationship.
      has_one :tube, relation_name: :tube
      has_many :libraries

      attributes :volume, :concentration, :template_prep_kit_box_barcode,
                 :insert_size, :created_at, :updated_at,
                 :library_attributes
      attribute :source_identifier, readonly: true

      # When a pool is updated and it is attached to a run we need
      # to republish the messages for the run
      after_update :publish_messages

      # Filters
      # join pool with tube as a pool has a barcode through tube
      filter :barcode, apply: lambda { |records, value, _options|
                                records.joins(:tube).where(tube: { barcode: value })
                              }

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
        @model.created_at.to_fs(:us)
      end

      def updated_at
        @model.updated_at.to_fs(:us)
      end

      def publish_messages
        Messages.publish(@model.sequencing_plates, Pipelines.pacbio.message)
      end
    end
  end
end
