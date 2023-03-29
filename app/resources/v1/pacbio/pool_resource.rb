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

      # We can only make this endpoint paginated when pacbio run create/edit page
      # No longer requires all records to be pulled back
      #
      # paginator :paged

      # def self.default_sort
      #   [{ field: 'created_at', direction: :desc }]
      # end

      filter :sample_name, apply: lambda { |records, value, _options|
        # We have to join requests and samples here in order to find by sample name
        records.joins(libraries: :sample).where(sample: { name: value })
      }

      filter :barcode, apply: lambda { |records, value, _options|
        records.joins(:tube).where(tube: { barcode: value })
      }

      # When a pool is updated and it is attached to a run we need
      # to republish the messages for the run
      after_update :publish_messages

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
