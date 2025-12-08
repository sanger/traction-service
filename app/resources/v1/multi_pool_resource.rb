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
  # For more information about JSON:API see the [JSON:API Specifications](https://jsonapi.org/format/)
  # or look at the [JSONAPI::Resources](http://jsonapi-resources.com/) package for the service
  # implementation of the JSON:API standard.
  class MultiPoolResource < JSONAPI::Resource
    # @!attribute [rw] pipeline
    #  @return [String] the pipeline associated with the multi_pool .e.g. "Pacbio" or "Ont"
    # @!attribute [rw] pool_method
    #  @return [Integer] the method used for pooling
    # @!attribute [rw] created_at
    #   @return [String] the creation date of the multi_pool in US format
    attributes :pool_method, :pipeline, :created_at

    # @!attribute [r] number_of_pools
    #  @return [Integer] a computed number of pools in the multi_pool
    attribute :number_of_pools, readonly: true

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
  end
end
