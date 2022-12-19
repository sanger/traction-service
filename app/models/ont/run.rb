# frozen_string_literal: true

module Ont
  # Ont::Run
  class Run < ApplicationRecord
    NAME_PREFIX = 'ONTRUN-'
    include Stateful

    # This association creates a link to the instrument this run belongs to.
    # We are setting to avoid automatic detection of inverse association from the instrument.
    # XXX: Do we need a default instrument to initialise the run with?
    belongs_to :instrument,
               class_name: 'Ont::Instrument',
               foreign_key: :ont_instrument_id,
               inverse_of: false

    has_many :flowcells, foreign_key: :ont_run_id, inverse_of: :run, dependent: :destroy

    # attr_accessor :experiment_name

    scope :active, -> { where(deactivated_at: nil) }

    # XXX: Should we check presence of flowcells too?
    validate :check_max_number_of_flowcells

    delegate :create_run!, to: :run_factory

    # Validate number of flowcells against max_number value of instrument
    def check_max_number_of_flowcells
      return if flowcells.length <= instrument.max_number_of_flowcells

      errors.add(:flowcells, 'must be less than instrument max number')
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

    def run_factory
      @run_factory ||= RunFactory.new(run: self)
    end

    private

    def generate_experiment_name
      return if experiment_name.present?

      update(experiment_name: "#{NAME_PREFIX}#{id}")
    end
  end
end
