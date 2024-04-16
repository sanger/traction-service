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

    # Method to calculate the used volume
    def used_volume
      derived_aliquots.sum(&:volume)
    end

    # Method to calculate the available volume
    def available_volume
      primary_aliquot.volume - used_volume
    end

    # Method to check if there is enough volume available
    def volume_check(required_volume)
      return true if available_volume >= required_volume

      errors.add(:base, 'Insufficient volume available')
      false
    end
  end
end
