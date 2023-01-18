# frozen_string_literal: true

module Ont
  # Ont::Run
  class Run < ApplicationRecord
    include Uuidable

    enum state: { pending: 0, completed: 1, user_terminated: 2, instrument_crashed: 3, restart: 4 }

    NAME_PREFIX = 'ONTRUN-' # Used for generating a unique experiment name for the run.

    # This association creates a link to the instrument this run belongs to.
    # We are setting inverse_of to false to avoid detection of inverse association.
    belongs_to :instrument,
               class_name: 'Ont::Instrument',
               foreign_key: :ont_instrument_id,
               inverse_of: false

    has_many :flowcells, foreign_key: :ont_run_id, inverse_of: :run, dependent: :destroy

    accepts_nested_attributes_for :flowcells, allow_destroy: true

    scope :active, -> { where(deactivated_at: nil) }

    # run flowcells validations
    validates :flowcells, presence: true
    validates :flowcells,
              length: {
                minimum: 1,
                message: lambda do |_object, _data|
                           'there must be at least one'
                         end
              }
    validates :flowcells,
              length: {
                maximum: :max_number_of_flowcells,
                if: :max_number_of_flowcells,
                message: lambda do |_object, _data|
                  'must be less than instrument max number'
                end
              }

    validate :flowcells, :position_uniqueness
    validate :flowcells, :pool_uniqueness
    validate :flowcells, :flowcell_id_uniqueness

    # Check if positions are duplicated in the run.
    def position_uniqueness
      positions = flowcells.collect(&:position)
      duplicates = positions.group_by { |f| f }.select { |_k, v| v.size > 1 }.map(&:first)

      duplicates.each do |position|
        errors.add(:flowcells, "position #{position} is duplicated in the same run")
      end
    end

    # Check if pools are duplicated in the run.
    def pool_uniqueness
      ont_pool_ids = flowcells.collect(&:ont_pool_id)
      duplicates = ont_pool_ids.group_by { |f| f }.select { |_k, v| v.size > 1 }.map(&:first)

      duplicates.each do |ont_pool_id|
        errors.add(:flowcells, "pool with id #{ont_pool_id} is duplicated in the same run")
      end
    end

    # Check if flowcell_ids are duplicated in the run.
    def flowcell_id_uniqueness
      flowcell_ids = flowcells.collect(&:flowcell_id)
      duplicates = flowcell_ids.group_by { |f| f }.select { |_k, v| v.size > 1 }.map(&:first)

      duplicates.each do |flowcell_id|
        message = "flowcell_id #{flowcell_id} is duplicated in the same run"

        errors.add(:flowcells, message)
      end
    end

    # Return the max_number of flowcells for the instrument if instrument is present.
    def max_number_of_flowcells
      instrument.present? && instrument.max_number_of_flowcells
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
