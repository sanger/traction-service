# frozen_string_literal: true

module Ont
  # Ont::Run
  class Run < ApplicationRecord
    include Uuidable

    # ONT Run states
    enum state: { pending: 0, completed: 1, user_terminated: 2, instrument_crashed: 3, restart: 4 }

    NAME_PREFIX = 'ONTRUN-' # Used for generating a unique experiment name for the run.

    # This association creates a link to the instrument this run belongs to.
    # We are setting inverse_of to false to avoid detection of inverse association.
    belongs_to :instrument, class_name: 'Ont::Instrument', foreign_key: :ont_instrument_id,
                            inverse_of: false

    # Run has many flowcells up to the instrument max number.
    has_many :flowcells, foreign_key: :ont_run_id, inverse_of: :run, dependent: :destroy

    # Allow nested attributes and enable saving them together with this run.
    accepts_nested_attributes_for :flowcells, allow_destroy: true

    scope :active, -> { where(deactivated_at: nil) }

    # number of flowcells
    # There must be at least one flowcell. Since it checks the min number of
    # flowcells, we do not need a separate presence validation.
    # The number of flowcells must be less than or equal to the instrument max number.

    validates :flowcells, length: {
      minimum: 1,
      message: :run_min_flowcells
    }
    validates :flowcells, length: {
      maximum: :max_number_of_flowcells, if: :max_number_of_flowcells,
      message: :run_max_flowcells
    }

    # position uniqueness
    # position must be unique within the run. Previously this validation was
    # on Flowcell as scoped uniqueness validation but it did not work as
    # expected when creating run and flowcells together.
    validate :flowcells, :position_uniqueness

    # flowcell_id uniqueness
    # flowcell_id must be unique within the run. Previously this validation was
    # on Flowcell as scoped uniqueness validation but it did not work as
    # expected when creating run and flowcells together.
    validate :flowcells, :flowcell_id_uniqueness

    # Check if positions are duplicated in the run.
    def position_uniqueness
      position_displays = flowcells.collect(&:position_display)
      duplicates = position_displays.group_by { |f| f }.select { |_k, v| v.size > 1 }.map(&:first)

      duplicates.each do |position_display|
        errors.add(:flowcells, :position_duplicated, display: position_display)
      end
    end

    # Check if flowcell_ids are duplicated in the run.
    def flowcell_id_uniqueness
      duplicates = flowcells.group_by(&:flowcell_id).select { |_k, v| v.size > 1 }.values.flatten

      duplicates.each do |flowcell|
        errors.add(:flowcells, :flowcell_id_duplicated, flowcell_id: flowcell.flowcell_id,
                                                        display: flowcell.position_display)
      end
    end

    # Return the max_number of flowcells for the instrument if instrument is present.
    def max_number_of_flowcells
      instrument&.max_number_of_flowcells
    end

    # Generate the experiment_name using the id of the run.
    after_create :generate_experiment_name

    def active?
      deactivated_at.nil?
    end

    def cancel
      return true unless active?

      update(deactivated_at: DateTime.current)
    end

    # Sets flowcells from an array of attributes (hash)
    # If there is no id in attributes, a new flowcell will be created.
    # If there is an id, existing flowcell will be updated.
    # If there is no attributes hash for an existing flowcell, it will be
    # deleted.
    # This method is called before validations, therefore it must properly
    # set up all flowcells to be saved together with the run. It must first
    # do the deletions and then "build" flowcells and "assign" attributes
    # without saving.

    def flowcell_attributes=(flowcell_options)
      transform_flowcell_attributes(flowcell_options)

      # Delete flowcells if attributes are not given
      options_ids = flowcell_options.pluck(:id).compact
      flowcells.each do |flowcell|
        flowcells.delete(flowcell) if options_ids.exclude? flowcell.id
      end

      # Update existing flowcells or build new ones
      flowcell_options.map do |attributes|
        if attributes[:id]
          update_flowcell(attributes)
        else
          create_flowcell(attributes)
        end
      end
    end

    private

    # Change attributes before using them
    # Strip and upcase flowcell_ids to accept case-insensitive barcodes.
    def transform_flowcell_attributes(flowcell_options)
      flowcell_options.each do |attributes|
        # because it is a frozen string
        if attributes[:flowcell_id]
          attributes[:flowcell_id] = attributes[:flowcell_id]&.strip&.upcase
        end
      end
    end

    # Assing attributes to an existing flowcell. The flowcell is found by the
    # id given in the attributes. If there is no flowcell with that id, an
    # exception is raised.
    def update_flowcell(attributes)
      matching = flowcells.select { |flowcell| flowcell.id == attributes[:id] }
      record_not_found(attributes[:id]) unless matching
      assign_flowcell_attributes(matching[0], attributes)
    end

    def record_not_found(id)
      raise ActiveRecord::RecordNotFound, "Ont flowcell #{id} does not exist"
    end

    # Create a new flowcell instance and assign attributes.
    def create_flowcell(attributes)
      new_flowcell = flowcells.build
      assign_flowcell_attributes(new_flowcell, attributes)
    end

    def assign_flowcell_attributes(flowcell, attributes)
      attributes.each do |key, value|
        method = "#{key}="
        flowcell.send(method, value) if flowcell.respond_to?(method)
      end
    end

    def generate_experiment_name
      return if experiment_name.present?

      update(experiment_name: "#{NAME_PREFIX}#{id}")
    end
  end
end
