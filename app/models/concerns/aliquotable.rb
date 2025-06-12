# frozen_string_literal: true

# Aliquotable
#
# This module provides functionality for models that can have aliquots.
# An aliquot is a portion or sample of a larger entity.
# Models that include this module will have associations and methods related to aliquots.
module Aliquotable
  extend ActiveSupport::Concern

  included do
    # Associations
    # Aliquots a general term to get all aliquots from a given source
    # Aliquots are polymorphic and can belong to any model
    has_many :aliquots, as: :source, dependent: :destroy

    # Used Aliquots are aliquots that have been used to create a new entity e.g a pool
    # they are intended to have a used_by association to the model that
    # they have been used by and a source association to the model that they were created from
    # Reverse of derived_aliquots
    has_many :used_aliquots, -> { where(aliquot_type: :derived) },
             as: :used_by, class_name: 'Aliquot',
             dependent: :destroy, inverse_of: :used_by

    # Primary Aliquot is the aliquot that is created when a new entity is created. This aliquot
    # is intended to be used to track the metadata e.g. volume and concentration of the entity
    has_one :primary_aliquot, -> { where(aliquot_type: :primary) },
            as: :source, class_name: 'Aliquot',
            dependent: :destroy, inverse_of: :source

    # Derived Aliquots are aliquots that have been created from an entity e.g. a library
    # they are used to track where an entity has been used.
    # Reverse of used_aliquots
    has_many :derived_aliquots, -> { where(aliquot_type: :derived) },
             as: :source, class_name: 'Aliquot',
             dependent: :nullify, inverse_of: :source

    # Method to calculate the used volume.
    # It sums up the volumes of all derived aliquots.
    # @return [Numeric] The total volume of all derived aliquots.
    def used_volume
      derived_aliquots.sum(&:volume)
    end

    # Method to calculate the available volume.
    # It subtracts the used volume from the volume of the primary aliquot.
    # @return [Numeric] The volume available in the primary aliquot after subtracting
    # the used volume and rounding to 2 decimal places.
    def available_volume
      (primary_aliquot.volume - used_volume).round(2)
    end

    # Method: is_available_volume_sufficient
    #
    # This method is used to validate if the available volume is sufficient for a required volume.
    # @return [Boolean] Returns true if the available volume is sufficient, false otherwise.
    def available_volume_sufficient?
      available_volume >= 0
    end

    # Method: primary_aliquot_volume_sufficient
    #
    # This method is used to validate the volume of the primary aliquot in the library.
    # It is typically used as a callback before updating a library record.
    #
    # The method performs the following checks:
    # 1. If the primary aliquot has not changed its volume, the method returns immediately
    # without performing any further checks.
    # 2. If the volume of the primary aliquot is greater than or equal to the used volume,
    # the method returns true.
    # 3. If the volume of the primary aliquot is less than the used volume,
    # the method adds an error to the library record and aborts the update operation.
    #
    # @return [nil, true, false] Returns nil if the primary aliquot has not changed its volume,
    #  true if the volume of the primary aliquot is greater than or equal to the used volume, and
    # false if the volume of the primary aliquot is less than the used volume.

    def primary_aliquot_volume_sufficient
      return unless primary_aliquot&.volume_changed?
      return true if primary_aliquot.volume >= used_volume

      errors.add(:volume, 'Volume must be greater than the current used volume')
      throw(:abort)
    end
  end

  # Method: used_aliquots_volume
  #
  # This method is used to validate the volume of used aliquots in a well.
  # It is typically used as a validation method before updating a pool record.
  # Returns false if the volume of any used aliquot is insufficient.
  def used_aliquots_volume
    # Get all the aliquots that are libraries or pools and have insufficient volume
    failed_aliquots = used_aliquots.select do |aliquot|
      ['Pacbio::Library', 'Pacbio::Pool'].include?(aliquot.source_type) &&
        !aliquot.source.available_volume_sufficient?
    end
    return if failed_aliquots.empty?

    # If there are failed aliquots we want to collect the source barcodes add an error to the pool
    failed_barcodes = failed_aliquots.map { |aliquot| aliquot.source.tube.barcode }.join(',')
    errors.add(:base, "Insufficient volume available for #{failed_barcodes}")
    false
  end
end
