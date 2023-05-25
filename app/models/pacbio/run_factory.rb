# frozen_string_literal: true

module Pacbio
  # Create or update a run
  class RunFactory
    include ActiveModel::Model
    extend NestedValidation

    validates_nested :run, :wells

    attr_reader :run, :well_attributes

    def construct_resources!
      ApplicationRecord.transaction do
        mark_removed_wells_for_destruction
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

      @well_attributes = attributes
      @well_ids = []

      well_attributes.map do |attrs|
        # remove the pool ids from the attributes and find the corresponding pool
        pool_ids = attrs.delete(:pools) || []
        pools = pool_ids.collect { |id| Pacbio::Pool.find(id) }

        id = attrs.delete(:id)

        @well_ids << id

        well = id.present? ? Pacbio::Well.find(id) : Pacbio::Well.new

        well.assign_attributes(**attrs, pools:, plate:)

        # build a well and it to the array of wells
        wells << well
      end
    end

    def wells
      @wells ||= []
    end

    def well_ids
      @well_ids ||= []
    end

    def plate
      @plate ||= run.plates.first || run.plates.build(run:)
    end

    def mark_removed_wells_for_destruction
      removed_well_ids = run.plates.first.wells.pluck(:id) - well_ids.compact
      removed_well_ids.map do |well_id|

        plate.wells.find_by(id: well_id).mark_for_destruction
  
      end
    end
  end
end
