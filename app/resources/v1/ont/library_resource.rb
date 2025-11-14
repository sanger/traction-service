# frozen_string_literal: true

module V1
  module Ont
    # Provides a JSON:API representation of {Ont::Library}.
    #
    ## Primary relationships:
    # * request {V1::Ont::RequestResource}
    # * tube {V1::Ont::TubeResource}
    # * pool {V1::Ont::PoolResource}
    # * tag {V1::Ont::TagResource}
    # * source_plate {V1::Ont::PlateResource}
    # * source_tube {V1::Ont::TubeResource}
    # * source_well {V1::Ont::WellResource}
    #
    # @note Access this resource via the `/v1/ont/libraries/` endpoint.
    #
    # @example
    #   curl -X GET http://localhost:3100/v1/ont/libraries
    #   curl -X GET http://localhost:3100/v1/pacbio/libraries/1?include=request,tube,pool
    #
    #   curl -X PATCH "http://localhost:3100/v1/ont/libraries/1"
    #     -H "Content-Type: application/vnd.api+json" \
    #     -H "Accept: application/vnd.api+json" \
    #      -d '{
    #         "data": {
    #           "type": "libraries",
    #           "id": "1",
    #           "attributes": {
    #             "volume": 5.0,
    #           }
    #         }
    #       }'
    #
    #   curl -X DELETE "http://localhost:3100/v1/ont/libraries/1"
    #
    class LibraryResource < JSONAPI::Resource
      model_name 'Ont::Library'

      # @!attribute [rw] volume
      #   @return [Float] the volume of the library
      # @!attribute [rw] kit_barcode
      #   @return [String] the barcode of the kit used
      # @!attribute [rw] concentration
      #   @return [Float] the concentration of the library
      # @!attribute [rw] insert_size
      #   @return [Integer] the insert size of the library
      # @!attribute [rw] created_at
      #   @return [String] the creation timestamp of the library
      # @!attribute [rw] deactivated_at
      #   @return [String, nil] the deactivation timestamp of the library, if any
      # @!attribute [rw] state
      #   @return [String] the state of the library
      attributes :volume, :kit_barcode, :concentration, :insert_size,
                 :created_at, :deactivated_at, :state

      has_one :request, always_include_optional_linkage_data: true
      # If we don't specify the relation_name here, jsonapi-resources
      # attempts to use_related_resource_records_for_joins
      # In this case I can see it using container_associations
      # so seems to be linking the wrong tube relationship.
      has_one :tube, relation_name: :tube
      has_one :tag, always_include_optional_linkage_data: true
      has_one :pool, always_include_optional_linkage_data: true
      has_one :source_well, relation_name: :source_well, class_name: 'Well'
      has_one :source_plate, relation_name: :source_plate, class_name: 'Plate'
      has_one :source_tube, relation_name: :source_tube, class_name: 'Tube'

      paginator :paged

      def self.records_for_populate(*_args)
        super.preload(source_well: :plate, request: :sample,
                      tag: :tag_set,
                      container_material: { container: :barcode })
      end

      def created_at
        @model.created_at.to_fs(:us)
      end

      def deactivated_at
        @model&.deactivated_at&.to_fs(:us)
      end
    end
  end
end
