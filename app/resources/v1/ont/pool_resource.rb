# frozen_string_literal: true

module V1
  module Ont
    # Provides a JSON:API representation of {Ont::Pool}.
    #
    ## Filters:
    # * barcode - Filter pools by the barcode of the associated tube.
    # * sample_name - Filter pools by the name of samples in the associated libraries.
    #
    ## Primary relationships:
    #
    # @note Access this resource via the `/v1/ont/pools/` endpoint.
    #
    # @example
    #   curl -X GET http://localhost:3100/v1/ont/pools
    #   curl -X GET http://localhost:3100/v1/ont/pools/15
    #   curl -X GET "http://localhost:3100/v1/ont/pools?filter[barcode]=TRAC-2-41"
    #   curl -X GET "http://localhost:3100/v1/ont/pools?filter[sample_name]=GENSAMPLE-1762592713-10
    #
    #   curl -X POST "http://localhost:3100/v1/ont/pools" \
    #     -H "accept: application/vnd.api+json" \
    #     -H "Content-Type: application/vnd.api+json" \
    #     -d '{
    #       "data": {
    #         "type": "pools",
    #         "attributes": {
    #           "volume": 10.0,
    #           "concentration": 5.0,
    #           "insert_size": 350,
    #           "kit_barcode": "KIT-12345",
    #           "library_attributes": [
    #             {
    #               "kit_barcode":"kit_barcode",
    #               "volume":1.111,
    #               "concentration":10.0,
    #               "insert_size":10000,
    #               "ont_request_id":36,
    #               "tag_id":1197
    #             },
    #             {
    #               "kit_barcode":"kit_barcode",
    #               "volume":1.111,
    #               "concentration":10.0,
    #               "insert_size":10000,
    #               "ont_request_id":36,
    #               "tag_id":1198
    #             }
    #           ]
    #         },
    #         "relationships": {
    #            "tube": {
    #              "data": {
    #                "type": "tubes",
    #                "id": "41"
    #             }
    #           }
    #         }
    #       }
    #     }'
    #
    #   curl -X PATCH "http://localhost:3100/v1/ont/pools/19" \
    #     -H "accept: application/vnd.api+json" \
    #     -H "Content-Type: application/vnd.api+json" \
    #     -d '{
    #       "data": {
    #          "id": "19",
    #         "type": "pools",
    #         "attributes": {
    #           "volume": 10.0,
    #           "concentration": 5.0,
    #           "insert_size": 350,
    #           "kit_barcode": "KIT-12345",
    #           "library_attributes": [
    #             {
    #               "kit_barcode":"kit_barcode",
    #               "volume":2.111,
    #               "concentration":10.0,
    #               "insert_size":10000,
    #               "ont_request_id":36,
    #               "tag_id":1197
    #             },
    #             {
    #               "kit_barcode":"kit_barcode",
    #               "volume":1.111,
    #               "concentration":20.0,
    #               "insert_size":10000,
    #               "ont_request_id":36,
    #               "tag_id":1198
    #             }
    #           ]
    #         }
    #       }
    #     }'
    #
    class PoolResource < JSONAPI::Resource
      model_name 'Ont::Pool'

      # If we don't specify the relation_name here, jsonapi-resources
      # attempts to use_related_resource_records_for_joins
      # In this case I can see it using container_associations
      # so seems to be linking the wrong tube relationship.
      has_one :tube, relation_name: :tube
      has_many :libraries

      # @!attribute [rw] volume
      #   @return [Float] the volume of the pool
      # @!attribute [rw] kit_barcode
      #   @return [String] the barcode of the kit used
      # @!attribute [rw] concentration
      #   @return [Float] the concentration of the pool
      # @!attribute [rw] insert_size
      #   @return [Integer] the insert size of the pool
      # @!attribute [r] created_at
      #   @return [String] the creation timestamp of the pool
      # @!attribute [r] updated_at
      #   @return [String] the last update timestamp of the pool
      # @!attribute [w] library_attributes
      #   @return [Array<Hash>] the attributes of the libraries in the pool
      # @!attribute [r] tube_barcode
      #   @return [String] the barcode of the tube
      attributes :volume, :kit_barcode, :concentration, :insert_size, :created_at, :updated_at,
                 :library_attributes, :tube_barcode

      # @!attribute [r] source_identifier
      #   @return [String] the source identifier of the pool
      attribute :source_identifier, readonly: true
      # @!attribute [r] final_library_amount
      #   @return [Float] the final amount of the library in the pool
      attribute :final_library_amount, readonly: true

      paginator :paged

      # This could be changed so a pool has a barcode through tube
      filter :barcode, apply: lambda { |records, value, _options|
        records.where(tube: Tube.where(barcode: value.map { |bc| bc.strip.upcase }))
      }

      filter :sample_name, apply: lambda { |records, value, _options|
        # We have to join requests and samples here in order to find by sample name
        records.joins(libraries: :sample).where(sample: { name: value })
      }

      def self.default_sort
        [{ field: 'created_at', direction: :desc }]
      end

      # # When a pool is updated and it is attached to a run we need
      # # to republish the messages for the run
      # after_update :publish_messages

      def library_attributes=(library_parameters)
        @model.library_attributes = library_parameters.map do |library|
          library.permit(:id, :volume, :kit_barcode, :concentration, :insert_size, :ont_request_id,
                         :tag_id)
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

      def tube_barcode
        @model.tube.barcode
      end
    end
  end
end
