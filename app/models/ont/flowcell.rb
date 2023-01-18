# frozen_string_literal: true

module Ont
  # Ont::Flowcell
  class Flowcell < ApplicationRecord
    include Uuidable

    # Run has many of these flowcells up to the maximum number for the instrument.
    belongs_to :run, foreign_key: :ont_run_id, inverse_of: :flowcells

    # We assume one-to-one relationship with pool.
    belongs_to :pool, foreign_key: :ont_pool_id, inverse_of: :flowcell

    delegate :requests, :libraries, to: :pool

    # flowcell position validations
    validates :position, presence: true
    validates :position, numericality: { only_integer: true }
    validates :position, numericality: {
      greater_than_or_equal_to: 1,
      less_than_or_equal_to: :max_number_of_flowcells,
      if: :max_number_of_flowcells,
      message: lambda do |_object, data|
        "position #{data[:value]} is out of range for the instrument"
      end
    }
    validates :position, uniqueness: {
      scope: :ont_run_id,
      message: lambda do |_object, data|
        "position #{data[:value]} is duplicated in the same run"
      end
    }

    # flowcell pool validations
    validates :ont_pool_id, uniqueness: {
      scope: :ont_run_id,
      message: lambda do |_object, data|
        "pool with id #{data[:value]} is duplicated in the same run"
      end
    }

    # flowcell_id barcode validations
    validates :flowcell_id, presence: true
    validates :flowcell_id,
              uniqueness: {
                message: lambda do |_object, data|
                  "flowcell_id #{data[:value]} has already been taken"
                end
              }

    # Return the max_number of flowcells for the instrument if run and instrument are present.
    def max_number_of_flowcells
      run.present? && run.instrument.present? && run.instrument.max_number_of_flowcells
    end
  end
end
