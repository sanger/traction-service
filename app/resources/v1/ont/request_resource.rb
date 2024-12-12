# frozen_string_literal: true

module V1
  module Ont
    # @todo This documentation does not yet include a detailed description of what this resource represents.
    # @todo This documentation does not yet include detailed descriptions for relationships, attributes and filters.
    # @todo This documentation does not yet include any example usage of the API via cURL or similar.
    #
    # @note Access this resource via the `/v1/ont/requests/` endpoint.
    #
    # Provides a JSON:API representation of {Ont::Request}.
    #
    # For more information about JSON:API see the [JSON:API Specifications](https://jsonapi.org/format/)
    # or look at the [JSONAPI::Resources](http://jsonapi-resources.com/) package
    # for the service implementation of the JSON:API standard.
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
      # @!attribute [rw] sample_name
      #   @return [String] the name of the sample
      # @!attribute [rw] source_identifier
      #   @return [String] the source identifier of the request
      # @!attribute [rw] created_at
      #   @return [String] the creation timestamp of the request
      attributes(*::Ont.request_attributes, :sample_name, :source_identifier, :created_at)

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
