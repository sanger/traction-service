# frozen_string_literal: true

module Pacbio
  # Create or update a run
  class PlateFactory
    include ActiveModel::Model
    extend NestedValidation

    validates_nested :well_factory

    attr_reader :well_attributes, :well_factory, :removed_well_ids

    attr_accessor :run

    # Create the run and all associated records
    # plates and wells
    def construct_resources!
      ApplicationRecord.transaction do
        # we have to do this first otherwise we would delete
        # newly created wells
        well_factory.construct_resources!
        # well_factory.mark_wells_to_remove_for_destruction
        # plate.save!
        # well_factory.destroy_removed_wells
      end
    end

    # Array describing the wells to create.
    # Each well consists of:
    # @param attributes [Array<Hash>] Array containing a hash describing the wells to build
    def well_attributes=(attributes)
      return if attributes.blank?

      @well_attributes = attributes

      @well_factory = WellFactory.new(plate:, well_attributes:)
    end

    # If the run is new build it otherwise return the firts plate
    def plate
      @plate ||= run.plates.first || run.plates.build(run:)
    end
  end
end
