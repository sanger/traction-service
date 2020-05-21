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

    def self.includes_args(except = nil)
      args = []
      args << { flowcells: Ont::Flowcell.includes_args(:run) } unless except == :flowcells

      args
    end

    def self.resolved_query
      Ont::Run.includes(*includes_args)
    end
  end
end
