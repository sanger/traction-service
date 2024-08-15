# frozen_string_literal: true

module V1
  module Ont
    # @todo This documentation does not yet include a detailed description of what this resource represents.
    # @todo This documentation does not yet include detailed descriptions for relationships, attributes and filters.
    # @todo This documentation does not yet include any example usage of the API via cURL or similar.
    #
    # @note Access this resource via the `/v1/ont/run/` endpoint.
    #
    # Provides a JSON:API representation of {Ont::Run}.
    #
    # For more information about JSON:API see the [JSON:API Specifications](https://jsonapi.org/format/)
    # or look at the [JSONAPI::Resources](http://jsonapi-resources.com/) package
    # for the service implementation of the JSON:API standard.
    class RunResource < JSONAPI::Resource
      model_name 'Ont::Run'

      # @!attribute [rw] experiment_name
      #   @return [String] the name of the experiment
      # @!attribute [rw] state
      #   @return [String] the state of the run
      # @!attribute [rw] created_at
      #   @return [String] the creation timestamp of the run
      # @!attribute [rw] ont_instrument_id
      #   @return [Integer] the ID of the associated instrument
      # @!attribute [rw] flowcell_attributes
      #   @return [Array<Hash>] the attributes of the flowcells in the run
      attributes :experiment_name, :state, :created_at, :ont_instrument_id, :flowcell_attributes

      # Run has an instrument. The foreign key is on this side.
      has_one :instrument, foreign_key: 'ont_instrument_id'

      # Run has many flowcells. The foreign key is on the other side.
      has_many :flowcells,
               foreign_key_on: :related,
               foreign_key: 'ont_run_id',
               class_name: 'Flowcell'

      filters :experiment_name, :state

      paginator :paged

      def self.default_sort
        [{ field: 'created_at', direction: :desc }]
      end

      after_create :publish_messages
      after_update :publish_messages

      def flowcell_attributes=(flowcell_parameters)
        @model.flowcell_attributes = flowcell_parameters.map do |flowcell|
          flowcell.permit(:id, :flowcell_id, :position, :ont_pool_id)
        end
      end

      def created_at
        @model.created_at.to_fs(:us)
      end

      def fetchable_fields
        super - [:flowcell_attributes]
      end

      def publish_messages
        Messages.publish(@model, Pipelines.ont.message)
      end
    end
  end
end
