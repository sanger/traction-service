# frozen_string_literal: true

module Pacbio
  # Create or update a run
  class RunFactory
    include ActiveModel::Model
    extend NestedValidation

    attr_accessor :run_attributes

    validates_nested :run, :wells

    def construct_resources!
      ApplicationRecord.transaction do
        run.save!
        plate.save!
      end
    end

    def well_attributes=(attributes)
      @well_attributes = attributes.map do |attrs|
        pool_ids = attrs.delete('pools') || []
        pools = pool_ids.collect { |id| Pacbio::Pool.find(id) }
        wells << Pacbio::Well.new(**attrs, pools:, plate:)
      end
    end

    def wells
      @wells ||= []
    end

    def run
      @run ||= Pacbio::Run.new(run_attributes)
    end

    def plate
      @plate ||= run.plates.build(run:)
    end
  end
end
