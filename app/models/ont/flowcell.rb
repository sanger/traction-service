# frozen_string_literal: true

module Ont
  # Ont::Flowcell
  class Flowcell < ApplicationRecord
    include Uuidable

    # Run has many of these flowcells up to the maximum number for the instrument.
    belongs_to :run, foreign_key: :ont_run_id, inverse_of: :flowcells

    # We assume one-to-one relationship with pool. We make it optional here to
    # customise the validation later.
    belongs_to :pool, foreign_key: :ont_pool_id, inverse_of: :flowcell, optional: true

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
      scope: :run,
      message: lambda do |_object, data|
        "position #{data[:value]} is duplicated in the same run"
      end
    }

    # pool validations
    validates :ont_pool_id, presence: {
      message: lambda do |object, _data|
        "pool at position #{object.device_id} is unknown"
      end
    }
    validates :pool, presence: {
      if: -> { ont_pool_id.present? },
      message: lambda do |object, _data|
        "pool at position #{object.device_id} is unknown"
      end
    }

    # flowcell_id barcode validations
    validates :flowcell_id, presence: {
      message: lambda do |object, data|
        "flowcell_id #{data[:value]} at position #{object.device_id} is missing"
      end
    }
    validates :flowcell_id, uniqueness: {
      scope: :run,
      message: lambda do |object, data|
        "flowcell_id #{data[:value]} at position #{object.device_id} is duplicated in the same run"
      end
    }

    # Return the max_number of flowcells for the instrument if run and instrument are present.
    def max_number_of_flowcells
      run.present? && run.instrument.present? && run.instrument.max_number_of_flowcells
    end

    # Returns alternative adressing for position
    def device_id
      map = device_id_map[run&.instrument&.instrument_type]
      if map
        map[position]
      else
        position
      end
    end

    def device_id_map
      @device_id_map ||= {
        PromethION: {
          1 => '1A', 2 => '1B', 3 => '1C', 4 => '1D',
          5 => '1E', 6 => '1F', 7 => '1G', 8 => '1H',
          9 => '2A', 10 => '2B', 11 => '2C', 12 => '2D',
          13 => '2E', 14 => '2F', 15 => '2G', 16 => '2H',
          17 => '3A', 18 => '3B', 19 => '3C', 20 => '3D',
          21 => '3E', 22 => '3F', 23 => '3G', 24 => '3H'
        }
      }.with_indifferent_access
    end
  end
end
