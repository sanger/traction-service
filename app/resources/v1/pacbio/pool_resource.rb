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
      has_many :used_aliquots, class_name: 'Aliquot', relation_name: :used_aliquots
      has_one :primary_aliquot, class_name: 'Aliquot', relation_name: :primary_aliquot
      has_many :requests
      has_many :libraries

      attributes :volume, :concentration, :template_prep_kit_box_barcode,
                 :insert_size, :created_at, :updated_at,
                 :library_attributes, :used_aliquots_attributes, :primary_aliquot_attributes,
                 :volume_tracking_attributes

      attribute :source_identifier, readonly: true

      ALIQUOT_ATTRIBUTES = %w[id volume concentration template_prep_kit_box_barcode insert_size
                              tag_id source_id source_type].freeze

      paginator :paged

      def self.default_sort
        [{ field: 'created_at', direction: :desc }]
      end

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

      def used_aliquots_attributes=(used_aliquot_parameters)
        @model.used_aliquots_attributes = used_aliquot_parameters.map do |aliquot|
          aliquot.permit(ALIQUOT_ATTRIBUTES).to_h.with_indifferent_access
        end
      end

      def primary_aliquot_attributes=(primary_aliquot_parameters)
        @model.primary_aliquot_attributes = primary_aliquot_parameters.permit(ALIQUOT_ATTRIBUTES)
      end

      def fetchable_fields
        super - %i[library_attributes used_aliquots_attributes primary_aliquot_attributes]
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
        Messages.publish(@model.sequencing_runs, Pipelines.pacbio.message)
      end

      def volume_tracking_attributes
        return unless Flipper.enabled?(:y24_153__expose_volume_tracking_attributes_on_pool_resource)

        attributes :used_volume, :available_volume
      end
    end
  end
end
