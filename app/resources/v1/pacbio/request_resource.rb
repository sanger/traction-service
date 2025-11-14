# frozen_string_literal: true

module V1
  module Pacbio
    # Provides a JSON:API representation of {Pacbio::Request}.
    #
    # For more information about JSON:API see the [JSON:API Specifications](https://jsonapi.org/format/)
    # or look at the [JSONAPI::Resources](http://jsonapi-resources.com/) package
    # for the service implementation of the JSON:API standard.
    # This resource represents a Pacbio Request and can return all requests, a single request or
    # multiple requests along with their relationships.
    #
    ## Filters:
    #
    # * sample_name
    # * source_identifier
    # * species
    #
    ## Primary relationships:
    #
    # * well {V1::Pacbio::WellResource}
    # * plate {V1::Pacbio::PlateResource}
    # * tube {V1::Pacbio::TubeResource}
    # * sample {V1::Pacbio::SampleResource}

    # ## Relationship trees:
    #
    # * well.plate
    # * plate.wells
    # * tube.requests
    #
    # @example
    #   curl -X GET http://localhost:3100/v1/pacbio/requests/1
    #   curl -X GET http://localhost:3100/v1/pacbio/requests/
    #   curl -X GET http://localhost:3100/v1/pacbio/requests/1?include=well,plate,tube
    #
    #   https://localhost:3100/v1/pacbio/requests?filter[sample_name]=sample_name
    #   https://localhost:3100/v1/pacbio/requests?filter[species]=species
    #
    #   https://localhost:3100/v1/pacbio/requests?filter[source_identifier]=TRAC-2-12068
    #
    #   https://localhost:3100/v1/pacbio/requests?filter[source_identifier]=TRAC-2-12068,TRAC-2-12066,TRAC-2-12067:A1
    #
    #   https://localhost:3100/v1/pacbio/requests?filter[source_identifier]=TRAC-2-12068,TRAC-2-12066,TRAC-2-12067&include=well.plate,plate.wells,tube.requests
    class RequestResource < JSONAPI::Resource
      include Shared::SourceIdentifierFilterable

      model_name 'Pacbio::Request', add_model_hint: false

      # @!attribute [rw] library_type
      #   @return [String] the type of the library
      # @!attribute [rw] estimate_of_gb_required
      #   @return [Float] the estimated gigabytes required
      # @!attribute [rw] number_of_smrt_cells
      #   @return [Integer] the number of SMRT cells
      # @!attribute [rw] cost_code
      #   @return [String] the cost code
      # @!attribute [rw] external_study_id
      #   @return [String] the external study ID
      attributes(*::Pacbio.request_attributes)

      # @!attribute [r] sample_name
      #   @return [String] the name of the sample
      # @!attribute [r] barcode
      #   @return [String] the barcode of the sample
      # @!attribute [r] sample_species
      #   @return [String] the species of the sample
      # @!attribute [r] created_at
      #   @return [String] the creation time of the request
      # @!attribute [r] source_identifier
      #   @return [String] the source identifier of the request
      # @!attribute [r] sample_retention_instrction
      #   @return [String] the retention instruction of the request
      attributes :sample_name, :barcode, :sample_species,
                 :created_at, :source_identifier, :sample_retention_instruction,
                 readonly: true

      # If we don't specify the relation_name here, jsonapi-resources
      # attempts to use_related_resource_records_for_joins
      # It pulls out the wrong ids. Seen similar behaviour over on pool_resource
      has_one :well, relation_name: :well
      has_one :plate, relation_name: :plate
      has_one :tube, relation_name: :tube
      has_one :sample, relation_name: :sample

      paginator :paged

      filter :species, apply: lambda { |records, value, _options|
        # We have to join requests and samples here in order to find by sample name
        # TODO: The below value[0] means we only take the first value passed in the filter
        #       If we want to support multiple values in one filter we would need to update this
        records.joins(:sample).where('species LIKE ?', "%#{value[0]}%")
      }

      filter :sample_name, apply: lambda { |records, value, _options|
        # We have to join requests and samples here in order to find by sample name
        records.joins(:sample).where(sample: { name: value })
      }

      filter :source_identifier, apply: lambda { |records, value, _options|
        apply_source_identifier_filter(records, value)
      }

      def self.default_sort
        [{ field: 'created_at', direction: :desc }]
      end

      # When a request is updated and it is attached to a run we need
      # to republish the messages for the run
      after_update :publish_messages

      def barcode
        @model&.tube&.barcode
      end

      def created_at
        @model.created_at.to_fs(:us)
      end

      def self.records_for_populate(*_args)
        super.preload(:sample, :tube, well: :plate)
      end

      def publish_messages
        Messages.publish(@model.sequencing_runs, Pipelines.pacbio.message)
      end
    end
  end
end
