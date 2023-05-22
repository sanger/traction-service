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

    ##
    # Array describing the wells to create.
    # Each well consists of:
    #
    # @param attributes [Array<Hash>] Array containing a hash describing the wells to build
    def well_attributes=(attributes)
      @well_attributes = attributes.map do |attrs|
        # remove the pool ids from the attributes and find the corresponding pool
        pool_ids = attrs.delete('pools') || []
        pools = pool_ids.collect { |id| Pacbio::Pool.find(id) }

        # build a well and it to the array of wells
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
