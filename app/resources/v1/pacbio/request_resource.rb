# frozen_string_literal: true

module V1
  module Pacbio
    # @todo This documentation does not yet include a detailed description of what this resource represents.
    # @todo This documentation does not yet include detailed descriptions for relationships, attributes and filters.
    # @todo This documentation does not yet include any example usage of the API via cURL or similar.
    #
    # @note Access this resource via the `/v1/pacbio/requests/` endpoint.
    #
    # Provides a JSON:API representation of {Pacbio::Request}.
    #
    # For more information about JSON:API see the [JSON:API Specifications](https://jsonapi.org/format/)
    # or look at the [JSONAPI::Resources](http://jsonapi-resources.com/) package
    # for the service implementation of the JSON:API standard.
    class RequestResource < JSONAPI::Resource
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
      # @!attribute [rw] sample_name
      #   @return [String] the name of the sample
      # @!attribute [rw] barcode
      #   @return [String] the barcode of the sample
      # @!attribute [rw] sample_species
      #   @return [String] the species of the sample
      # @!attribute [rw] created_at
      #   @return [String] the creation time of the request
      # @!attribute [rw] source_identifier
      #   @return [String] the source identifier of the request
      attributes(*::Pacbio.request_attributes, :sample_name, :barcode, :sample_species,
                 :created_at, :source_identifier)

      # If we don't specify the relation_name here, jsonapi-resources
      # attempts to use_related_resource_records_for_joins
      # It pulls out the wrong ids. Seen similar behaviour over on pool_resource
      has_one :well, relation_name: :well
      has_one :plate, relation_name: :plate
      has_one :tube, relation_name: :tube

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
        # First we check tubes to see if there are any given the source identifier
        recs = records.joins(:tube).where(tube: { barcode: value })
        return recs unless recs.empty?

        # If no tubes match the source identifier we check plates
        # If source identifier specifies a well we need to match samples to well
        # TODO: The below value[0] means we only take the first value passed in the filter
        #       If we want to support multiple values in one filter we would need to update this
        plate, well = value[0].split(':')
        recs = records.joins(:plate).where(plate: { barcode: plate })
        well ? recs.joins(:well).where(well: { position: well }) : recs
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
