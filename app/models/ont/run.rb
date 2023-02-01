# frozen_string_literal: true

module Ont
  # Ont::Run
  class Run < ApplicationRecord
    include Uuidable

    enum state: { pending: 0, completed: 1, user_terminated: 2, instrument_crashed: 3, restart: 4 }

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

    validate :check_max_number_of_flowcells, :check_flowcell_position, :check_flowcell_pool

    def check_flowcell_position
      return if instrument.blank?

      position_set = Set.new
      flowcells.each do |flowcell|
        next if flowcell.position.blank?

        if flowcell.position < 1 || flowcell.position > instrument.max_number_of_flowcells
          errors.add(:flowcells, "position #{flowcell.position} is out of range for the instrument")
        elsif position_set.include? flowcell.position
          errors.add(:flowcells, "position #{flowcell.position} is duplicated in the same run")
        else
          position_set.add(flowcell.position)
        end
      end
    end

    def check_flowcell_pool
      pool_set = Set.new
      flowcells.each do |flowcell|
        next if flowcell.ont_pool_id.blank?

        if pool_set.include? flowcell.ont_pool_id
          errors.add(:flowcells, "pool #{flowcell.ont_pool_id} is duplicated in the same run")
        else
          pool_set.add(flowcell.ont_pool_id)
        end
      end
    end

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

    # returns sample sheet csv for a Ont::Run
    # using pipelines.yml configuration to generate data
    def generate_sample_sheet
      sample_sheet = OntSampleSheet.new(run: self, configuration: ont_run_sample_sheet_config)
      sample_sheet.generate
    end

    private

    def ont_run_sample_sheet_config
      Pipelines.ont.sample_sheet.by_version('v1')
    end

    def update_flowcell(attributes)
      id = attributes[:id].to_s
      indexed_flowcells.fetch(id) { missing_flowcell(id) }
                       .tap { |flowcell| flowcell.update(attributes) }
    end

    def missing_flowcell(id)
      raise ActiveRecord::RecordNotFound, "Ont flowcell #{id} does not exist"
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
