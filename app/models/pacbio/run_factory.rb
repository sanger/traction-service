# frozen_string_literal: true

module Pacbio
  # Create or update a run
  class RunFactory
    include ActiveModel::Model
    extend NestedValidation

    validates_nested :run, :wells

    attr_reader :run

    def construct_resources!
      ApplicationRecord.transaction do
        run.save!
        plate.save!
      end
    end

    def run_attributes=(attributes)
      id = attributes.delete(:id)
      @run ||= id.present? ? Pacbio::Run.find(id) : Pacbio::Run.new
      @run.assign_attributes(attributes)
      @run_attributes = attributes
    end

    ##
    # Array describing the wells to create.
    # Each well consists of:
    #
    # @param attributes [Array<Hash>] Array containing a hash describing the wells to build
    def well_attributes=(attributes)
      return if attributes.blank?

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

    def plate
      @plate ||= run.plates.first || run.plates.build(run:)
    end
  end
end
