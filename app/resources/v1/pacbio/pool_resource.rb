# frozen_string_literal: true

module V1
  module Pacbio
    # @todo This documentation does not yet include a detailed description of what this resource represents.
    # @todo This documentation does not yet include detailed descriptions for relationships, attributes and filters.
    # @todo This documentation does not yet include any example usage of the API via cURL or similar.
    #
    # @note Access this resource via the `/v1/pacbio/pool/` endpoint.
    #
    # Provides a JSON:API representation of {Pacbio::Pool}.
    #
    # For more information about JSON:API see the [JSON:API Specifications](https://jsonapi.org/format/)
    # or look at the [JSONAPI::Resources](http://jsonapi-resources.com/) package
    # for the service implementation of the JSON:API standard.
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

      # @!attribute [rw] volume
      #   @return [Float] the volume of the pool
      # @!attribute [rw] concentration
      #   @return [Float] the concentration of the pool
      # @!attribute [rw] template_prep_kit_box_barcode
      #   @return [String] the barcode of the template prep kit box
      # @!attribute [rw] insert_size
      #   @return [Integer] the insert size of the pool
      # @!attribute [rw] created_at
      #   @return [String] the creation time of the pool
      # @!attribute [rw] updated_at
      #   @return [String] the last update time of the pool
      # @!attribute [rw] library_attributes
      #   @return [Hash] the attributes of the library
      # @!attribute [rw] used_aliquots_attributes
      #   @return [Array<Hash>] the attributes of the used aliquots
      # @!attribute [rw] primary_aliquot_attributes
      #   @return [Hash] the attributes of the primary aliquot
      # @!attribute [rw] used_volume
      #   @return [Float] the used volume of the pool
      # @!attribute [rw] available_volume
      #   @return [Float] the available volume of the pool
      attributes :volume, :concentration, :template_prep_kit_box_barcode,
                 :insert_size, :created_at, :updated_at,
                 :library_attributes, :used_aliquots_attributes, :primary_aliquot_attributes,
                 :used_volume, :available_volume

      # @!attribute [r] source_identifier
      #   @return [String] the source identifier of the pool
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

      # publish messages when a pool is created
      after_create :publish_messages_on_creation

      # When a pool is updated and it is attached to a run we need
      # to republish the messages for the run
      after_update :publish_messages_on_update

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

      def publish_messages_on_creation
        Emq::Publisher.publish(@model.primary_aliquot, Pipelines.pacbio, 'volume_tracking')
      end

      def publish_messages_on_update
        Messages.publish(@model.sequencing_runs, Pipelines.pacbio.message)
        Emq::Publisher.publish(@model.primary_aliquot, Pipelines.pacbio, 'volume_tracking')
      end
    end
  end
end
