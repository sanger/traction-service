# frozen_string_literal: true

module V1
  module Pacbio
    # Provides a JSON:API representation of {Pacbio::Library}.
    #
    # For more information about JSON:API see the [JSON:API Specifications](https://jsonapi.org/format/)
    # or look at the [JSONAPI::Resources](http://jsonapi-resources.com/) package
    # for the service implementation of the JSON:API standard.
    # This resource represents a Pacbio Library and can return all libraries, a single library or
    # multiple libraries along with their relationships.
    #
    # ## Filters:
    #
    # * sample_name
    # * barcode
    # * source_identifier
    #
    # ## Primary relationships:
    #
    # * request {V1::Pacbio::RequestResource}
    # * tube {V1::Pacbio::TubeResource}
    # * pool {V1::Pacbio::PoolResource}
    #
    # ## Relationship trees:
    #
    # * request.sample
    # * tube.requests
    # * pool.libraries
    #
    # @example
    #   curl -X GET http://localhost:3000/v1/pacbio/libraries/1
    #   curl -X GET http://localhost:3000/v1/pacbio/libraries/
    #   curl -X GET http://localhost:3000/v1/pacbio/libraries/1?include=request,tube,pool
    #
    #   https://localhost:3000/v1/pacbio/libraries?filter[sample_name]=sample_name
    #   https://localhost:3000/v1/pacbio/libraries?filter[barcode]=TRAC-2-12068
    #
    #   https://localhost:3000/v1/pacbio/libraries?filter[barcode]=TRAC-2-12068,TRAC-2-12066,TRAC-2-12067
    #
    #   https://localhost:3000/v1/pacbio/libraries?filter[barcode]=TRAC-2-12068,TRAC-2-12066,TRAC-2-12067&include=request.sample,tube.requests,pool.libraries
    class LibraryResource < JSONAPI::Resource
      include Shared::RunSuitability
      include Shared::SourceIdentifierFilterable

      model_name 'Pacbio::Library'

      # @!attribute [rw] state
      #   @return [String] the state of the library
      # @!attribute [rw] volume
      #   @return [Float] the volume of the library
      # @!attribute [rw] concentration
      #   @return [Float] the concentration of the library
      # @!attribute [rw] template_prep_kit_box_barcode
      #   @return [String] the barcode of the template prep kit box
      # @!attribute [rw] insert_size
      #   @return [Integer] the insert size of the library
      # @!attribute [rw] created_at
      #   @return [String] the creation time of the library
      # @!attribute [rw] deactivated_at
      #   @return [DateTime, nil] the deactivation time of the library, or nil if not
      #    deactivated
      # @!attribute [rw] source_identifier
      #   @return [String] the source identifier of the library
      # @!attribute [rw] pacbio_request_id
      #   @return [Integer] the ID of the associated PacBio request
      # @!attribute [rw] tag_id
      #   @return [Integer] the ID of the associated tag
      # @!attribute [rw] primary_aliquot_attributes
      #   @return [Hash] the attributes of the primary aliquot
      # @!attribute [rw] used_volume
      #   @return [Float] the used volume of the library
      # @!attribute [rw] available_volume
      #   @return [Float] the available volume of the library
      attributes :state, :volume, :concentration, :template_prep_kit_box_barcode,
                 :insert_size, :created_at, :deactivated_at, :source_identifier,
                 :pacbio_request_id, :tag_id, :primary_aliquot_attributes,
                 :used_volume, :available_volume

      # @!attribute [r] barcode
      #  @return [String] the barcode of the library (via tube)
      attribute :barcode, readonly: true

      has_one :request, always_include_optional_linkage_data: true
      # If we don't specify the relation_name here, jsonapi-resources
      # attempts to use_related_resource_records_for_joins
      # In this case I can see it using container_associations
      # so seems to be linking the wrong tube relationship.
      has_one :tag, always_include_optional_linkage_data: true
      has_one :tube, relation_name: :tube, always_include_optional_linkage_data: true
      has_one :source_well, relation_name: :source_well, class_name: 'Well'
      has_one :source_plate, relation_name: :source_plate, class_name: 'Plate'

      has_one :primary_aliquot, always_include_optional_linkage_data: true,
                                relation_name: :primary_aliquot, class_name: 'Aliquot'
      has_many :used_aliquots, always_include_optional_linkage_data: true,
                               relation_name: :used_aliquots, class_name: 'Aliquot'

      paginator :paged

      def self.default_sort
        [{ field: 'created_at', direction: :desc }]
      end

      # When a library is updated and it is attached to a run we need
      # to republish the messages for the run
      after_update :publish_messages

      after_create :publish_volume_tracking_messages

      filter :sample_name, apply: lambda { |records, value, _options|
        # We have to join requests and samples here in order to find by sample name
        records.joins(:sample).where(sample: { name: value })
      }
      filter :barcode, apply: lambda { |records, value, _options|
        # If wildcard is the last value passed we want to do a wildcard search
        if value.last == 'wildcard'
          return records.joins(:tube).where('tubes.barcode LIKE ?', "%#{value[0]}%")
        end

        records.joins(:tube).where(tubes: { barcode: value })
      }
      filter :source_identifier, apply: lambda { |records, value, _options|
        apply_source_identifier_filter(records, value, joins: { plate: :source_plate,
                                                                tube: :source_tube,
                                                                well: :source_well })
      }

      def self.records_for_populate(*_args)
        super.preload(source_well: :plate, request: :sample,
                      tag: :tag_set,
                      container_material: { container: :barcode })
      end

      def primary_aliquot_attributes=(primary_aliquot_parameters)
        @model.primary_aliquot_attributes = primary_aliquot_parameters.permit(
          :id, :volume, :template_prep_kit_box_barcode,
          :concentration, :insert_size, :tag_id
        )
      end

      def fetchable_fields
        super - [:primary_aliquot_attributes]
      end

      def created_at
        @model.created_at.to_fs(:us)
      end

      def deactivated_at
        @model&.deactivated_at&.to_fs(:us)
      end

      def publish_messages
        Messages.publish(@model.sequencing_runs, Pipelines.pacbio.message)
        publish_volume_tracking_messages
      end

      def publish_volume_tracking_messages
        Emq::Publisher.publish([@model.primary_aliquot, *@model.used_aliquots],
                               Pipelines.pacbio, 'volume_tracking')
      end
    end
  end
end
