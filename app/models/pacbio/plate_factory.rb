# frozen_string_literal: true

module Pacbio
  # Create or update a run
  class PlateFactory
    include ActiveModel::Model
    extend NestedValidation

    validates_nested :wells

    attr_reader :well_attributes, :removed_well_ids

    attr_accessor :run

    # Create the run and all associated records
    # plates and wells
    def construct_resources!
      ApplicationRecord.transaction do
        # we have to do this first otherwise we would delete
        # newly created wells
        mark_wells_to_remove_for_destruction
        plate.save!
        destroy_removed_wells
      end
    end

    # Array describing the wells to create.
    # Each well consists of:
    # @param attributes [Array<Hash>] Array containing a hash describing the wells to build
    def well_attributes=(attributes)
      return if attributes.blank?

      @well_attributes = attributes

      well_attributes.map do |attrs|
        # remove the pool ids from the attributes and find the corresponding pool
        pool_ids = attrs.delete(:pools) || []
        pools = pool_ids.collect { |id| Pacbio::Pool.find(id) }

        # if the well has an id retrieve it from the database
        # if it is new build a new well
        # finally assign the attributes to the well
        well = attrs[:id].present? ? plate.wells.find_by(id: attrs[:id]) : Pacbio::Well.new
        well.assign_attributes(**attrs.except(:id), pools:, plate:)
        wells << well
      end
    end

    def wells
      @wells ||= []
    end

    # get list of all of the well ids that have been passed
    def well_ids
      return [] if well_attributes.blank?

      @well_ids ||= well_attributes.pluck(:id).compact
    end

    # Get all of the ids for the current wells and then
    # check that against well ids that have been passed to return
    # a list of well ids to be removed
    def well_ids_for_removal
      return if well_attributes.blank?

      @well_ids_for_removal ||= run.plates.first.wells.pluck(:id) - well_ids
    end

    # If the run is new build it otherwise return the firts plate
    def plate
      @plate ||= run.plates.first || run.plates.build(run:)
    end

    # Any wells that are no longer being used should be marked for destruction
    # so that they are not validated for any well specific validation
    def mark_wells_to_remove_for_destruction
      return if well_attributes.blank?

      well_ids_for_removal.map do |well_id|
        plate.wells.find { |well| well.id == well_id }.mark_for_destruction
      end
    end

    # delete any wells that were not passed in as they are no longer used
    def destroy_removed_wells
      return if well_attributes.blank?

      Pacbio::Well.where(id: well_ids_for_removal).destroy_all
    end
  end
end
