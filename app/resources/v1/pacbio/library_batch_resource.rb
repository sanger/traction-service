# frozen_string_literal: true

module V1
  module Pacbio
    # This resource is used to create batches of libraries in one go.
    #
    # @example
    #  {
    #     "data": {
    #       "type": "library_batches",
    #       "attributes": {
    #         "libraries_attributes": [
    #           {
    #             "volume": 50.2,
    #             "concentration": 2.222,
    #             "template_prep_kit_box_barcode": "LK1234567",
    #             "insert_size": 100,
    #             "pacbio_request_id": 1,
    #             "tag_id": 1,
    #             "primary_aliquot_attributes": {
    #               "volume": 50.2,
    #               "concentration": 2.222,
    #               "template_prep_kit_box_barcode": "LK1234567",
    #               "insert_size": 100,
    #               "tag_id": 1
    #             },
    #           }
    #         ]
    #       }
    #   }
    #
    # @note Access this resource via the `/v1/pacbio/library_batches/` endpoint.
    #
    # Provides a JSON:API representation of {Pacbio::LibraryBatch}.
    #
    # For more information about JSON:API see the [JSON:API Specifications](https://jsonapi.org/format/)
    # or look at the [JSONAPI::Resources](http://jsonapi-resources.com/) package
    # for the service implementation of the JSON:API standard.
    class LibraryBatchResource < JSONAPI::Resource
      model_name 'Pacbio::LibraryBatch'

      # @!attribute [w] created_at
      #   @return [String] the creation time of the library
      # @!attribute [w] libraries_attributes
      #  @return [Array] the attributes of the libraries
      attributes :created_at, :libraries_attributes

      has_many :libraries, always_include_optional_linkage_data: true

      def libraries_attributes=(libraries_attributes_parameters)
        @model.libraries_attributes = libraries_attributes_parameters.map do |library|
          library.permit(
            :volume, :template_prep_kit_box_barcode,
            :concentration, :insert_size, :tag_id,
            :pacbio_request_id,
            primary_aliquot_attributes: %i[
              volume concentration template_prep_kit_box_barcode insert_size tag_id
            ]
          )
        end
      end

      def fetchable_fields
        super - [:libraries_attributes]
      end
    end
  end
end
