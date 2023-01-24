# frozen_string_literal: true

module Ont
  # Ont::Run
  class Run < ApplicationRecord
    include Uuidable

    enum state: { pending: 0, completed: 1, user_terminated: 2, instrument_crashed: 3, restart: 4 }

    NAME_PREFIX = 'ONTRUN-' # Used for generating a unique experiment name for the run.

    # This association creates a link to the instrument this run belongs to.
    # We are setting inverse_of to false to avoid detection of inverse association.
    belongs_to :instrument, class_name: 'Ont::Instrument', foreign_key: :ont_instrument_id,
                            inverse_of: false

    has_many :flowcells, foreign_key: :ont_run_id, inverse_of: :run, dependent: :destroy

    accepts_nested_attributes_for :flowcells, allow_destroy: true

    scope :active, -> { where(deactivated_at: nil) }

    # run flowcells validations
    validates :flowcells, presence: true
    validates :flowcells, length: {
      minimum: 1,
      message: lambda do |_object, _data|
                 'there must be at least one flowcell'
               end
    }
    validates :flowcells, length: {
      maximum: :max_number_of_flowcells, if: :max_number_of_flowcells,
      message: lambda do |_object, _data|
                 'number of flowcells must be less than instrument max number'
               end
    }

    validate :flowcells, :position_uniqueness
    validate :flowcells, :flowcell_id_uniqueness

    # Check if positions are duplicated in the run.
    def position_uniqueness
      positions = flowcells.collect(&:device_id)
      duplicates = positions.group_by { |f| f }.select { |_k, v| v.size > 1 }.map(&:first)

      duplicates.each do |position|
        message = "position #{position} is duplicated in the same run"

        errors.add(:flowcells, message) unless errors_messages.include? message
      end
    end

    # Check if flowcell_ids are duplicated in the run.
    def flowcell_id_uniqueness
      duplicates = flowcells.group_by(&:flowcell_id).select { |_k, v| v.size > 1 }.values.flatten

      duplicates.each do |flowcell|
        message = "flowcell_id #{flowcell.flowcell_id} at position " \
                  "#{flowcell.device_id} is duplicated in the same run"

        errors.add(:flowcells, message) unless errors_messages.include? message
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
      transform_flowcell_attributes(flowcell_options)

      options_ids = flowcell_options.pluck(:id).compact
      flowcells.each do |flowcell|
        flowcells.delete(flowcell) if options_ids.exclude? flowcell.id
      end

      flowcell_options.map do |attributes|
        if attributes[:id]
          update_flowcell(attributes)
        else
          create_flowcell(attributes)
        end
      end
    end

    # Returns error messages added so far
    def errors_messages
      errors.messages.values.flatten
    end

    private

    def transform_flowcell_attributes(flowcell_options)
      flowcell_options.each do |attributes|
        # because it is a frozen string
        if attributes[:flowcell_id]
          attributes[:flowcell_id] = attributes[:flowcell_id]&.strip&.upcase
        end
      end
    end

    def update_flowcell(attributes)
      matching = flowcells.select { |flowcell| flowcell.id == attributes[:id] }
      case matching.length
      when 1
        assign_flowcell_attributes(matching[0], attributes)
      when 0
        raise ActiveRecord::RecordNotFound, "Ont flowcell #{id} does not exist"
      else
        raise ActiveRecord::RecordNotUnique, "Ont flowcell #{id} is duplicated"
      end
    end

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
