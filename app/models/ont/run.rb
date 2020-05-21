# frozen_string_literal: true

module Ont
  # Ont::Run
  class Run < ApplicationRecord
    include Stateful

    has_many :flowcells, foreign_key: :ont_run_id, inverse_of: :run, dependent: :destroy

    scope :active, -> { where(deactivated_at: nil) }

    def active?
      deactivated_at.nil?
    end

    def cancel
      return true unless active?

      update(deactivated_at: DateTime.current)
    end

    def experiment_name
      "ONTRUN-#{id}"
    end

    def resolved_run
      self.class.resolved_query.find(id)
    end

    def self.includes_hash(*except_keys)
      return {} if except_keys.include?(:flowcells)

      { flowcells: Ont::Flowcell.includes_hash(:run) }
    end

    def self.resolved_run(id:)
      resolved_query.find(id)
    end

    def self.all_resolved_runs
      resolved_query.all
    end

    def self.resolved_query
      Ont::Run.includes(includes_hash)
    end
  end
end
