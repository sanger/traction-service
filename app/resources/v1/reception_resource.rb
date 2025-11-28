# frozen_string_literal: true

module V1
  # Provides a JSON:API representation of {Reception}.
  #
  # A reception handles the import of samples and requests from external
  # sources. It accepts plates_attributes, tubes_attributes, pool_attributes,
  # or compound_sample_tubes_attributes. It publishes sample and stock_resource
  # messages.
  #
  # @note Access this resource via the `/v1/receptions` endpoint.
  #
  # @example
  #   curl -X GET http://localhost:3100/v1/receptions
  #   curl -X GET http://localhost:3100/v1/receptions/1
  #
  #   curl -X POST http://localhost:3100/v1/receptions \
  #     -H "Content-Type: application/vnd.api+json" \
  #     -H "Accept: application/vnd.api+json" \
  #     -d '{
  #       "data": {
  #         "type": "receptions",
  #         "attributes": {
  #           "source": "tol-lab-share.tol",
  #           "tubes_attributes": [
  #             {
  #               "type": "tubes",
  #               "barcode": "NT1",
  #               "request": {
  #                 "external_study_id": "36961ba5-c291-494d-a3e5-67a915782121",
  #                 "cost_code": "S10000",
  #                 "library_type": "Library Type 1",
  #                 "data_type": "Data Type 1"
  #               },
  #               "sample": {
  #                 "name": "Sample1",
  #                 "external_id": "8ad0fd55-8a30-41e0-b37e-7e5010af929b",
  #                 "species": "human",
  #                 "public_name": "PublicName",
  #                 "priority_level": "Medium",
  #                 "country_of_origin": "United Kingdom",
  #                 "retention_instruction": "return_to_customer_after_2_years",
  #                 "number_of_donors": null
  #               }
  #             }
  #           ]
  #         }
  #       }
  #     }'
  #
  #   curl -X POST http://localhost:3100/v1/receptions \
  #     -H "Content-Type: application/vnd.api+json" \
  #     -H "Accept: application/vnd.api+json" \
  #     -d '{
  #       "data": {
  #         "type": "receptions",
  #         "attributes": {
  #           "source": "traction-ui.sequencescape",
  #           "plates_attributes": [
  #             {
  #               "type": "plates",
  #               "barcode": "NT1",
  #               "wells_attributes": [
  #                 {
  #                   "position": "A1",
  #                   "request": {
  #                     "external_study_id": "839e22dc-b3e9-4f88-b77b-7921be082d3f",
  #                     "cost_code": "S10006",
  #                     "library_type": "Library Type 6",
  #                     "data_type": "Data Type 6"
  #                   },
  #                   "sample": {
  #                     "name": "Sample7",
  #                     "external_id": "e23f8315-8c08-4307-88d0-46141664a2b4",
  #                     "species": "human",
  #                     "public_name": "PublicName",
  #                     "priority_level": "Medium",
  #                     "country_of_origin": "United Kingdom",
  #                     "retention_instruction": "return_to_customer_after_2_years",
  #                     "number_of_donors": null
  #                   }
  #                 }
  #               ]
  #             }
  #           ]
  #         }
  #       }
  #     }'
  #
  #   curl -X POST http://localhost:3100/v1/receptions \
  #     -H "Content-Type: application/vnd.api+json" \
  #     -H "Accept: application/vnd.api+json" \
  #     -d '{
  #       "data": {
  #         "type": "receptions",
  #         "attributes": {
  #           "source": "traction-ui.sequencescape",
  #           "tubes_attributes": [
  #             {
  #               "type": "tubes",
  #               "barcode": "NT1",
  #               "request": {
  #                 "external_study_id": "df3a95a0-9fac-4d6c-b151-c2f94f4c5df5",
  #                 "cost_code": "S10011",
  #                 "library_type": "Library Type 8",
  #                 "data_type": "Data Type 8"
  #               },
  #               "library": {
  #                 "volume": 1,
  #                 "concentration": 2,
  #                 "insert_size": 3,
  #                 "kit_barcode": "Tag-Set-1",
  #                 "tag_sequence": "TGTGAA1CC"
  #               },
  #               "sample": {
  #                 "name": "Sample12",
  #                 "external_id": "08f35d53-15a1-480f-b033-560a5b1bfb82",
  #                 "species": "human",
  #                 "public_name": "PublicName",
  #                 "priority_level": "Medium",
  #                 "country_of_origin": "United Kingdom",
  #                 "retention_instruction": "return_to_customer_after_2_years",
  #                 "number_of_donors": null
  #               }
  #             },
  #             {
  #               "type": "tubes",
  #               "barcode": "NT2",
  #               "request": {
  #                 "external_study_id": "437b08d2-1502-45a6-95c7-00e4ef84b5b0",
  #                 "cost_code": "S10012",
  #                 "library_type": "Library Type 8",
  #                 "data_type": "Data Type 8"
  #               },
  #               "library": {
  #                 "volume": 1,
  #                 "concentration": 2,
  #                 "insert_size": 3,
  #                 "kit_barcode": "Tag-Set-1",
  #                 "tag_sequence": "AGACGCTT2"
  #               },
  #               "sample": {
  #                 "name": "Sample13",
  #                 "external_id": "ddd937a5-ca29-4ecb-a62b-b76f00fef683",
  #                 "species": "human",
  #                 "public_name": "PublicName",
  #                 "priority_level": "Medium",
  #                 "country_of_origin": "United Kingdom",
  #                 "retention_instruction": "return_to_customer_after_2_years",
  #                 "number_of_donors": null
  #               }
  #             },
  #             {
  #               "type": "tubes",
  #               "barcode": "NT3",
  #               "request": {
  #                 "external_study_id": "b5e84718-bef0-4fd1-ae3b-13951c1e5c2d",
  #                 "cost_code": "S10013",
  #                 "library_type": "Library Type 8",
  #                 "data_type": "Data Type 8"
  #               },
  #               "library": {
  #                 "volume": 1,
  #                 "concentration": 2,
  #                 "insert_size": 3,
  #                 "kit_barcode": "Tag-Set-1",
  #                 "tag_sequence": "CTAGAGC3T"
  #               },
  #               "sample": {
  #                 "name": "Sample14",
  #                 "external_id": "c974d7d1-d618-404e-b1b0-6d5e19f2bd87",
  #                 "species": "human",
  #                 "public_name": "PublicName",
  #                 "priority_level": "Medium",
  #                 "country_of_origin": "United Kingdom",
  #                 "retention_instruction": "return_to_customer_after_2_years",
  #                 "number_of_donors": null
  #               }
  #             }
  #           ],
  #           "pool_attributes": {
  #             "volume": 1,
  #             "concentration": 2,
  #             "insert_size": 3,
  #             "kit_barcode": "Tag-Set-1",
  #             "barcode": "NT123"
  #           }
  #         }
  #       }
  #     }'
  #
  class ReceptionResource < JSONAPI::Resource
    # @!attribute [rw] source
    #   @return [String] the source of the reception
    # @!attribute [w] labware
    #   @return [Array<Hash>] the labware associated with the reception
    # @!attribute [w] plates_attributes
    #   @return [Array<Hash>] the attributes of the plates
    # @!attribute [w] tubes_attributes
    #   @return [Array<Hash>] the attributes of the tubes
    # @!attribute [w] pool_attributes
    #   @return [Hash] the attributes of the pool
    # @!attribute [w] compound_sample_tubes_attributes
    #   @return [Array<Hash>] the attributes of the compound sample tubes
    attributes :source, :labware, :plates_attributes, :tubes_attributes, :pool_attributes,
               :compound_sample_tubes_attributes

    after_create :publish_messages, :construct_resources!

    def fetchable_fields
      %i[source labware]
    end

    def self.creatable_fields(context)
      super - [:labware]
    end

    def labware
      context[:labware] || []
    end

    private

    def plates_attributes=(plate_parameters)
      raise ArgumentError unless plate_parameters.is_a?(Array)

      @model.plates_attributes = plate_parameters.map do |plate|
        plate.permit(
          :barcode,
          wells_attributes: [
            :position,
            { request: permitted_request_attributes,
              sample: permitted_sample_attributes }
          ]
        ).to_h.with_indifferent_access
      end
    end

    def tubes_attributes=(tube_parameters)
      raise ArgumentError unless tube_parameters.is_a?(Array)

      @model.tubes_attributes = tube_parameters.map do |tube|
        tube.permit(
          :barcode,
          library: permitted_library_attributes,
          request: permitted_request_attributes,
          sample: permitted_sample_attributes
        ).to_h.with_indifferent_access
      end
    end

    # method to handle incoming compound tube parameters
    def compound_sample_tubes_attributes=(compound_tube_parameters)
      raise ArgumentError unless compound_tube_parameters.is_a?(Array)

      # call model method to set compound tubes attributes
      @model.compound_sample_tubes_attributes = compound_tube_parameters.map do |tube|
        tube.permit(
          :barcode,
          library: permitted_library_attributes,
          request: permitted_request_attributes,
          samples: permitted_sample_attributes
        ).to_h.with_indifferent_access
      end
    end

    def pool_attributes=(pool_parameters)
      raise ArgumentError unless pool_parameters.is_a?(Object)

      @model.pool_attributes = pool_parameters.permit(
        *permitted_pool_attributes
      ).to_h.with_indifferent_access
    end

    def construct_resources!
      # Use context to cache the labware to be used in the response
      context[:labware] = @model.construct_resources!
    end

    def permitted_pool_attributes
      [*::Ont.pool_attributes, :barcode]
    end

    def permitted_library_attributes
      [*::Pacbio.library_attributes, *::Ont.library_attributes, :tag_sequence].uniq
    end

    def permitted_request_attributes
      [*::Pacbio.request_attributes, *::Ont.request_attributes].uniq
    end

    def permitted_sample_attributes
      %i[name external_id species study_uuid priority_level public_name
         sanger_sample_id supplier_name taxon_id donor_id country_of_origin
         accession_number date_of_sample_collection retention_instruction]
    end

    def publish_messages
      # Only publish messages if source is publishable
      return unless @model.publish_source?

      # Publish message for the sample table
      publish_message(
        @model.requests.map(&:sample),
        Pipelines.reception.sample.message
      )
      # Publish message for the stock_resource table
      publish_message(
        @model.requests,
        Pipelines.reception.stock_resource.message
      )
    end

    def publish_message(message, config)
      Messages.publish(message, config)
    end
  end
end
