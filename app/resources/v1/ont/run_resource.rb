# frozen_string_literal: true

module V1
  module Ont
    # RunResource
    class RunResource < JSONAPI::Resource
      model_name 'Ont::Run'

      attributes :experiment_name, :state, :created_at, :ont_instrument_id

      # Run has an instrument. The foreign key is on this side.
      has_one :instrument, foreign_key: 'ont_instrument_id', class_name: 'Instrument'

      # Run has many flowcells. The foreign key is on the other side.
      has_many :flowcells,
               foreign_key_on: :related,
               foreign_key: 'ont_run_id',
               class_name: 'Flowcell'

      after_create :create_run!

      def create_run!
        @model.create_run!
      end
    end
  end
end
