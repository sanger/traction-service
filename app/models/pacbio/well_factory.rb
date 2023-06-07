# frozen_string_literal: true

module Pacbio
  class WellFactory
    # provides model-like behaviour
    include ActiveModel::Model

    extend NestedValidation

    validates_nested :wells

    attr_reader :well_attributes
    attr_accessor :plate

    def construct_resources!
      mark_wells_to_remove_for_destruction
      well.save!
      destroy_removed_wells
    end

    # if wells do not exist, initialises as an empty array
    def wells
      @wells ||= []
    end

    def well_attributes=(attributes)
      return if attributes.blank?

      @well_attributes = attributes

      well_attributes.map do |attrs|
        # remove the pool id from the attributes and find the corresponding pool
        pool_ids = attrs.delete(:pools) || []
        pools = pool_ids.collect { |id| Pacbio::Pool.find(id) }

        # if the well has an id retrieve it from the database
        # if it is new build a new well
        # assign the attributes to the well
        well = attrs[:id].present? ? plate.wells.find_by(id: attrs[:id]) : Pacbio::Well.new
        well.assign_attributes(**attrs.except(:id), pools:, plate:)
        wells << well
      end
    end

    # get an array of all well IDs from well_attributes array
    def well_ids
      return [] if well_attributes.blank?

      @well_ids ||= well_attributes.pluck(:id).compact
    end

    # get the new wells by filtering the well attributes by wells with no ids
    def new_wells
      @new_wells ||= well_attributes.reject { |attrs| attrs[:id].nil? }
    end

    # get the existing wells by filtering the well attributes by wells with existing ids
    def existing_wells
      @existing_wells ||= well_attributes.select { |attrs| attrs[:id].nil? }
    end

    # get all ids for current wells, check against the well_ids above
    # the ones not there are to be removed
    def well_ids_for_removal
      return if well_attributes.blank?

      @well_ids_for_removal ||= run.plates.first.wells.pluck(:id) - well_ids
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
