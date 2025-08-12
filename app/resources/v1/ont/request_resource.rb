# frozen_string_literal: true

module V1
  module Ont
    # Provides a JSON:API representation of {Ont::Request}.
    #
    # @note Access this resource via the `/v1/ont/requests/` endpoint.
    #
    # For more information about JSON:API see the [JSON:API Specifications](https://jsonapi.org/format/)
    # or look at the [JSONAPI::Resources](http://jsonapi-resources.com/) package
    # for the service implementation of the JSON:API standard.
    # This resource represents an ONT Request and can return all requests, a single request or
    # multiple requests along with their relationships.
    #
    # ## Filters:
    #
    # * sample_name
    # * source_identifier
    #

    # ## Relationship trees:
    #
    # * well.plate
    # * plate.wells
    # * tube.requests
    #
    # @example
    #   curl -X GET http://localhost:3000/v1/ont/requests/1
    #   curl -X GET http://localhost:3000/v1/ont/requests/
    #
    #   https://localhost:3000/v1/ont/requests?filter[sample_name]=sample_name
    #
    #   https://localhost:3000/v1/ont/requests?filter[source_identifier]=mock-plate-2:B12
    #
    #   https://localhost:3000/v1/ont/requests?filter[source_identifier]=mock-plate-2:B12,mock-plate-2:C1
    #
    class RequestResource < JSONAPI::Resource
      include Shared::SourceIdentifierFilterable
      model_name 'Ont::Request', add_model_hint: false

      # @!attribute [rw] library_type
      #   @return [String] the type of the library
      # @!attribute [rw] data_type
      #   @return [String] the type of the data
      # @!attribute [rw] cost_code
      #   @return [String] the cost code associated with the request
      # @!attribute [rw] external_study_id
      #   @return [String] the external study identifier
      # @!attribute [rw] number_of_flowcells
      #   @return [Integer] the number of flowcells requested
      attributes(*::Ont.request_attributes)

      # @!attribute [r] sample_name
      #   @return [String] the name of the sample
      # @!attribute [r] sample_retention_instruction
      #   @return [String] the retention instruction for the sample
      # @!attribute [r] source_identifier
      #   @return [String] the source identifier of the request
      # @!attribute [r] created_at
      #   @return [String] the creation timestamp of the request
      attributes :sample_name, :sample_retention_instruction, :source_identifier, :created_at,
                 readonly: true

      paginator :paged

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

      def created_at
        @model.created_at.to_fs(:us)
      end

      def library_type
        @model.library_type.name
      end

      def library_type=(name)
        @model.library_type = LibraryType.find_by(name:)
      end

      def data_type
        @model.data_type.name
      end

      def data_type=(name)
        @model.data_type = DataType.find_by(name:)
      end

      def self.records_for_populate(*_args)
        super.preload(:library_type, :data_type)
      end
    end
  end
end
