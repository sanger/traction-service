# frozen_string_literal: true

module V1
  module Ont
    # RunResource
    class RunResource < JSONAPI::Resource
      model_name 'Ont::Run'

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
