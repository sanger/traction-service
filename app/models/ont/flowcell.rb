# frozen_string_literal: true

module Ont
  # Ont::Flowcell
  class Flowcell < ApplicationRecord
    include Uuidable

    # flowcell_ids have 3 letters followed by 3 numbers
    FLOWCELL_ID_FORMAT = 'ABC%03d'

    # Run has many of these flowcells up to the maximum number for the instrument.
    belongs_to :run, foreign_key: :ont_run_id, inverse_of: :flowcells

    # We assume one-to-one relationship with pool. We make it optional here to
    # remove the default presence validation to customise the validations below.
    belongs_to :pool, foreign_key: :ont_pool_id, inverse_of: :flowcell, optional: true

    delegate :requests, :libraries, to: :pool

    # flowcell position validations
    # position must exist.
    # position must be an integer.
    # position must be in range between one and the max number of the instrument.
    # position must be unique among the others in the same run. This scoped
    # position uniqueness within the run is validated by run because the scoped
    # uniqueness validation does not work properly when run does not have an id
    # and it accepts nested attributes to autosave its flowcells.
    # Numericality validations are listed separately to avoid duplicated
    # validation keys.

    validates :position, presence: true
    validates :position, numericality: { only_integer: true }
    validates :position, numericality: {
      greater_than_or_equal_to: 1,
      less_than_or_equal_to: :max_number_of_flowcells,
      if: :max_number_of_flowcells,
      message: :position_out_of_range
    }

    # pool validations
    # pool must exist. The error message is given as "is unknown" because of
    # how the UI shows the message. The UI gets a tube barcode and finds the
    # corresponding pool. If it can't find the pool, it sends a nil
    # ont_pool_id . When it shows the error message, the invalid tube barcode
    # entered by the user is still shown in the page. If the error message was
    # "is required" or "is missing", it would be confusing.
    # We do not validate ont_pool_id separately as the presence of the pool
    # covers it.
    # We used generate_message to be able to pass options from this object.
    validates :pool, presence: {
      message: lambda { |object, _data|
        object.errors.generate_message(:pool, :pool_unknown, display: object.position_display)
      }
    }

    # flowcell_id validations
    # flowcell_id must exist.
    # flowcell_id uniqueness within the run is validated by run because the scoped
    # uniqueness validation does not work properly when run does not have an id
    # and it accepts nested attributes to autosave its flowcells.
    # # We used generate_message to be able to pass options from this object.
    validates :flowcell_id, presence: {
      message: lambda { |object, _data|
        object.errors.generate_message(
          :flowcell_id, :flowcell_id_missing, display: object.position_display
        )
      }
    }

    # Return the max_number of flowcells for the instrument if run and instrument are present.
    def max_number_of_flowcells
      run&.max_number_of_flowcells
    end

    # Returns alternative adressing for position if available
    def position_display
      map = position_display_map[run&.instrument&.instrument_type]
      if map
        map[position]
      else
        position
      end
    end

    private

    # Maps positions to alternative addressing for instruments
    def position_display_map
      @position_display_map ||= {
        PromethION: promethion_position_displays,
        GridION: gridion_position_displays
      }.with_indifferent_access
    end

    # Generates alternative adressing for promethION, A1..H1, A2..H2, and A3..H3
    def promethion_position_displays
      position_displays = (1..3).flat_map do |i|
        ('A'..'H').flat_map do |j|
          "#{i}#{j}"
        end
      end
      position_displays.each_with_index.to_h { |v, i| [i + 1, v] }
    end

    # Generates alternative adressing for gridION, x1..x5
    def gridion_position_displays
      (1..5).index_with { |i| "x#{i}" }
    end
  end
end
