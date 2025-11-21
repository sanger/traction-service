# frozen_string_literal: true

module V1
  module Ont
    # This resource represents a sequencing run for the Oxford Nanopore Technologies (ONT) platform.
    # It provides a JSON:API representation of {Ont::Run}.
    #
    # ## Attributes:
    #
    # * experiment_name: The name of the experiment.
    # * state: The state of the run.
    # * rebasecalling_process: The rebasecalling process of the run.
    # * created_at: The creation timestamp of the run.
    # * ont_instrument_id: The ID of the associated instrument.
    # * flowcell_attributes: The attributes of the flowcells in the run.
    #
    ## Filters:
    #
    # * experiment_name: Filter runs by experiment name.
    # * state: Filter runs by state.
    #
    ## Primary relationships:
    #
    # * instrument {V1::Ont::InstrumentResource}
    # * flowcells {V1::Ont::FlowcellResource}
    #
    # ## Relationship trees:
    #
    # * flowcells.pool
    #
    # @note Access this resource via the `/v1/ont/runs/` endpoint.
    #
    # @example
    #   curl -X GET "http://localhost:3100/v1/ont/runs" -H "accept: application/vnd.api+json"
    #
    #   curl -X GET "http://localhost:3100/v1/ont/runs/1?include=flowcells.pool" \
    #        -H "accept: application/vnd.api+json"
    #
    #   curl -X POST "http://localhost:3100/v1/ont/runs" \
    #    -H "accept: application/vnd.api+json" \
    #    -H "Content-Type: application/vnd.api+json" \
    #    -d '{
    #       "data": {
    #       "type": "runs",
    #       "attributes": {
    #         "experiment_name": "Experiment 1",
    #         "state": "pending",
    #         "rebasecalling_process": "process_1",
    #         "ont_instrument_id": 1,
    #         "flowcell_attributes": [
    #           {
    #             "id": 1,
    #             "flowcell_id": "flowcell_1",
    #             "position": "A1",
    #             "ont_pool_id": 1
    #           },
    #          {
    #             "id": 2,
    #             "flowcell_id": "flowcell_2",
    #             "position": "B1",
    #             "ont_pool_id": 2
    #          }
    #         ]
    #        }
    #       }
    #      }'
    #
    #   curl -X PATCH "http://localhost:3100/v1/ont/runs/1" \
    #    -H "accept: application/vnd.api+json" \
    #    -H "Content-Type: application/vnd.api+json" \
    #    -d '{"data": {"type": "runs", "id": "1", "attributes": {"state": "completed"}}}'
    #
    class RunResource < JSONAPI::Resource
      model_name 'Ont::Run'

      # @!attribute [rw] experiment_name
      #   @return [String] the name of the experiment
      # @!attribute [rw] state
      #   @return [String] the state of the run
      # @!attribute [rw] rebasecalling_process
      #   @return [String] the rebasecalling process of the run
      # @!attribute [rw] created_at
      #   @return [String] the creation timestamp of the run
      # @!attribute [rw] ont_instrument_id
      #   @return [Integer] the ID of the associated instrument
      # @!attribute [rw] flowcell_attributes
      #   @return [Array<Hash>] the attributes of the flowcells in the run
      attributes :experiment_name, :state, :rebasecalling_process, :created_at, :ont_instrument_id,
                 :flowcell_attributes

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
