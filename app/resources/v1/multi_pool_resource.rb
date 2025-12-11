# frozen_string_literal: true

module V1
  # `MultiPoolResource` provides a **JSON:API** representation of the `MultiPool` model.
  # It allows API clients to query, filter, and retrieve multi-pool-related information.
  #
  # @note Access this resource via the `/v1/multi_pools` endpoint.
  #
  # Provides a JSON:API representation of {MultiPool} and exposes valid request
  # for use by the UI.
  #
  # Filters:
  # * pipeline
  # * pool_method
  # * pool_barcode
  #
  # Primary relationships:
  # * multi_pool_positions {V1::MultiPoolPositionResource}
  #
  # @example
  #  curl -X GET http://localhost:3100/v1/multi_pools
  #  curl -X GET http://localhost:3100/v1/multi_pools/1
  #  curl -X GET "http://localhost:3100/v1/multi_pools/1?include=multi_pool_positions"
  #  curl -X GET "http://localhost:3100/v1/multi_pools?filter[pipeline]=pacbio"
  #  curl -X POST "http://localhost:3100/v1/multi_pools" \
  #     -H "accept: application/vnd.api+json" \
  #     -H "Content-Type: application/vnd.api+json" \
  #     -d '{
  #       "data": {
  #         "type": "multi_pools",
  #         "attributes": {
  #            "pool_method": "Plate",
  #            "pipeline": "pacbio",
  #            "multi_pool_positions_attributes": [
  #              {
  #                "position": "A1",
  #                "pcbio_pool_attributes": {
  #                  "template_prep_kit_box_barcode": "LK1234567",
  #                  "volume": 1.11,
  #                  "concentration": 2.22,
  #                  "insert_size": 100,
  #                  "used_aliquots_attributes": [
  #                    {
  #                      "volume": 1.11,
  #                      "template_prep_kit_box_barcode": "LK1234567",
  #                      "concentration": 2.22,
  #                      "insert_size": 100,
  #                      "source_id": 1,
  #                      "source_type": "Pacbio::Request",
  #                      "tag_id": 1
  #                    }
  #                  ],
  #                  "primary_aliquot_attributes": {
  #                    "volume": 200,
  #                    "concentration": 22,
  #                    "template_prep_kit_box_barcode": 100,
  #                    "insert_size": 11
  #                  }
  #                }
  #              }
  #            ]
  #          }
  #        }
  #       }'
  #  curl -X PATCH "http://localhost:3100/v1/multi_pools/2" \
  #      -H "accept: application/vnd.api+json" \
  #      -H "Content-Type: application/vnd.api+json" \
  #      -d '{
  #           "data": {
  #               "type": "multi_pools",
  #               "id": "2",
  #               "attributes": {
  #                   "pool_method": "Plate",
  #                   "pipeline": "pacbio",
  #                   "multi_pool_positions_attributes": [
  #                       {
  #                           "id": 2,
  #                           "position": "A1",
  #                           "pacbio_pool_attributes": {
  #                               "id": 15,
  #                               "template_prep_kit_box_barcode": "LK1234567",
  #                               "volume": 1.11,
  #                               "concentration": 2.22,
  #                               "insert_size": 100,
  #                               "used_aliquots_attributes": [
  #                                   {
  #                                       "id": 363,
  #                                       "volume": 1.11,
  #                                       "template_prep_kit_box_barcode": "LK1234567",
  #                                       "concentration": 2.22,
  #                                       "insert_size": 100,
  #                                       "source_id": 1,
  #                                       "source_type": "Pacbio::Request",
  #                                       "tag_id": 1
  #                                   }
  #                               ],
  #                               "primary_aliquot_attributes": {
  #                                   "id": 364,
  #                                   "volume": 200,
  #                                   "concentration": 22,
  #                                   "template_prep_kit_box_barcode": 100,
  #                                   "insert_size": 11
  #                               }
  #                           }
  #                       }
  #                   ]
  #               }
  #           }
  #         }'
  #
  class MultiPoolResource < JSONAPI::Resource
    # @!attribute [rw] pipeline
    #  @return [String] the pipeline associated with the multi_pool .e.g. "Pacbio" or "Ont"
    # @!attribute [rw] pool_method
    #  @return [Integer] the method used for pooling
    attributes :pool_method, :pipeline

    # @!attribute [r] number_of_pools
    #  @return [Integer] a computed number of pools in the multi_pool
    # @!attribute [r] created_at
    #  @return [String] the creation date of the multi_pool in US format via override below
    attributes :number_of_pools, :created_at, readonly: true

    # @!attribute [w] multi_pool_position_attributes
    #  @return [Array<Hash>] attributes for creating/updating nested multi_pool_positions
    attribute :multi_pool_positions_attributes

    has_many :multi_pool_positions, always_include_optional_linkage_data: true

    paginator :paged

    filter :pipeline
    filter :pool_method

    filter :pool_barcode, apply: lambda { |records, value, _options|
      pacbio_pools = records.joins(multi_pool_positions: { pacbio_pool: :tube })
                            .where(tubes: { barcode: value })
      ont_pools = records.joins(multi_pool_positions: { ont_pool: :tube })
                         .where(tubes: { barcode: value })
      records.where(id: pacbio_pools.select(:id)).or(records.where(id: ont_pools.select(:id)))
    }

    # Handle behaviour for messages after creation and update of multi pools
    after_create :publish_messages_on_creation
    after_update :publish_messages_on_update

    def self.default_sort
      [{ field: 'created_at', direction: :desc }]
    end

    def created_at
      @model.created_at.to_fs(:us)
    end

    MULTI_POOL_POSITIONS_ATTRIBUTES = %w[id position
                                         pacbio_pool_attributes].freeze
    PACBIO_POOL_ATTRIBUTES = %w[id volume concentration template_prep_kit_box_barcode
                                insert_size created_at updated_at
                                library_attributes used_aliquots_attributes
                                primary_aliquot_attributes
                                used_volume available_volume].freeze
    ALIQUOT_ATTRIBUTES = %w[id volume concentration template_prep_kit_box_barcode insert_size
                            tag_id source_id source_type].freeze

    # We need to override the setter to permit nested attributes
    # for multi_pool_positions and their nested pacbio_pools
    # and their nested used_aliquots and primary_aliquot
    def multi_pool_positions_attributes=(multi_pool_positions_parameters) # rubocop:disable Metrics/MethodLength
      @model.multi_pool_positions_attributes = multi_pool_positions_parameters.map do |mpp|
        mpp.permit(
          *MULTI_POOL_POSITIONS_ATTRIBUTES,
          :_destroy,
          pacbio_pool_attributes: [
            :_destroy,
            *PACBIO_POOL_ATTRIBUTES,
            { used_aliquots_attributes: [
                :_destroy,
                *ALIQUOT_ATTRIBUTES
              ],
              primary_aliquot_attributes: [
                *ALIQUOT_ATTRIBUTES
              ] }
          ]
        ).to_h.with_indifferent_access
      end
    end

    def fetchable_fields
      super - %i[multi_pool_positions_attributes]
    end

    def publish_messages_on_creation
      # Collect pacbio pools only
      @model.multi_pool_positions.each do |mpp|
        next if mpp.pacbio_pool.blank?

        # Publish volume tracking message for each pacbio pool's primary aliquot
        Emq::Publisher.publish(mpp.pacbio_pool.primary_aliquot, Pipelines.pacbio, 'volume_tracking')
      end
    end

    def publish_messages_on_update
      @model.multi_pool_positions.each do |mpp|
        next if mpp.pacbio_pool.blank?

        # Publish volume tracking message for each pacbio pool's primary aliquot
        Emq::Publisher.publish(mpp.pacbio_pool.primary_aliquot, Pipelines.pacbio, 'volume_tracking')
        # Publish messages for sequencing runs associated with the pool
        # This may not be the most efficient way as a multi pool may be updated without every pool
        # being changed, but it ensures all runs are up to date
        Messages.publish(mpp.pacbio_pool.sequencing_runs, Pipelines.pacbio.message)
      end
    end
  end
end
