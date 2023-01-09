# frozen_string_literal: true

module Ont
  # Ont::Run
  class Run < ApplicationRecord
    include Stateful
    include Uuidable

    NAME_PREFIX = 'ONTRUN-' # Used for generating a unique experiment name for the run.

    # This association creates a link to the instrument this run belongs to.
    # We are setting to avoid automatic detection of inverse association from the instrument.
    # XXX: Do we need a default instrument to initialise the run with?
    belongs_to :instrument,
               class_name: 'Ont::Instrument',
               foreign_key: :ont_instrument_id,
               inverse_of: false

    has_many :flowcells, foreign_key: :ont_run_id, inverse_of: :run, dependent: :destroy

    accepts_nested_attributes_for :flowcells, allow_destroy: true

    scope :active, -> { where(deactivated_at: nil) }

    validate :check_max_number_of_flowcells

    def check_max_number_of_flowcells
      return if instrument.blank?

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

    def flowcell_attributes=(flowcell_options)
      self.flowcells = flowcell_options.map do |attributes|
        if attributes[:id]
          update_flowcell(attributes)
        else
          Ont::Flowcell.new(attributes)
        end
      end
    end

    private

    def update_flowcell(attributes)
      id = attributes[:id].to_s
      indexed_flowcells.fetch(id) { missing_flowcell(id) }
                       .tap { |flowcell| flowcell.update(attributes) }
    end

    def missing_flowcell(id)
      raise ActiveRecord::RecordNotFound, "Ont flowcell #{id} is not part of the pool"
    end

    def indexed_flowcells
      @indexed_flowcells ||= flowcells.index_by { |flowcell| flowcell.id.to_s }
    end

    def generate_experiment_name
      return if experiment_name.present?

      update(experiment_name: "#{NAME_PREFIX}#{id}")
    end
  end
end
