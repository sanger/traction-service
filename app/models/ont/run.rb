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

    # This association creates the link to the MinKnowVersion. Run belongs
    # to a MinKnowVersion. We set the default MinKnowVersion for the run
    # using the class method 'default'.
    belongs_to :min_know_version,
               class_name: 'Ont::MinKnowVersion',
               foreign_key: :ont_min_know_version_id,
               inverse_of: :runs,
               default: -> { MinKnowVersion.default }

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
      position_names = flowcells.collect(&:position_name)
      duplicates = position_names.group_by { |f| f }.select { |_k, v| v.size > 1 }.map(&:first)

      duplicates.each do |position_name|
        errors.add(:flowcells, :position_duplicated, position_name:)
      end
    end

    # Check if flowcell_ids are duplicated in the run.
    def flowcell_id_uniqueness
      duplicates = flowcells.group_by(&:flowcell_id).select { |_k, v| v.size > 1 }.values.flatten

      duplicates.each do |flowcell|
        errors.add(:flowcells, :flowcell_id_duplicated, flowcell_id: flowcell.flowcell_id,
                                                        position_name: flowcell.position_name)
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
      # Delete flowcells if attributes are not given
      options_ids = flowcell_options.pluck(:id).compact
      flowcells.each do |flowcell|
        flowcells.delete(flowcell) if options_ids.exclude? flowcell.id
      end

      # Update existing flowcells or create new ones
      flowcell_options.map do |attributes|
        if attributes[:id]
          flowcells.find(attributes[:id]).assign_attributes(attributes)
        else
          flowcells.build(attributes)
        end
      end
    end

    # returns sample sheet csv for a Ont::Run
    # using pipelines.yml configuration to generate data
    def generate_sample_sheet
      sample_sheet = OntSampleSheet.new(run: self, configuration: ont_run_sample_sheet_config)
      sample_sheet.generate
    end

    private

    def ont_run_sample_sheet_config
      Pipelines.ont.sample_sheet.by_version(min_know_version.name)
    end

    def generate_experiment_name
      return if experiment_name.present?

      update(experiment_name: "#{NAME_PREFIX}#{id}")
    end
  end
end
