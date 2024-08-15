# frozen_string_literal: true

module V1
  module Saphyr
    # @todo This documentation does not yet include a detailed description of what this resource represents.
    # @todo This documentation does not yet include detailed descriptions for relationships, attributes and filters.
    # @todo This documentation does not yet include any example usage of the API via cURL or similar.
    #
    # @note Access this resource via the `/v1/saphyr/runs/` endpoint.
    #
    # Provides a JSON:API representation of {Saphyr::Run}.
    #
    # For more information about JSON:API see the [JSON:API Specifications](https://jsonapi.org/format/)
    # or look at the [JSONAPI::Resources](http://jsonapi-resources.com/) package
    # for the service implementation of the JSON:API standard.
    class RunResource < JSONAPI::Resource
      model_name 'Saphyr::Run'

      # @!attribute [rw] state
      #   @return [String] the state of the run
      # @!attribute [rw] chip_barcode
      #   @return [String] the barcode of the chip
      # @!attribute [rw] created_at
      #   @return [String] the creation timestamp of the run
      # @!attribute [rw] name
      #   @return [String] the name of the run
      attributes :state, :chip_barcode, :created_at, :name

      has_one :chip, foreign_key_on: :related, foreign_key: 'saphyr_run_id'

      def chip_barcode
        @model&.chip&.barcode
      end

      def created_at
        @model.created_at.to_fs(:us)
      end

      def self.records(_options = {})
        ::Saphyr::Run.active
      end
    end
  end
end
