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

    private

    def device_id_map
      @device_id_map ||= {
        PromethION: promethion_device_ids
      }.with_indifferent_access
    end

    def promethion_device_ids
      device_ids = (1..3).flat_map do |i|
        ('A'..'H').flat_map do |j|
          "#{i}#{j}"
        end
      end
      device_ids.each_with_index.to_h { |v, i| [i + 1, v] }
    end
  end
end
