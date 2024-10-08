# frozen_string_literal: true

# Information about ONT instruments, received by email:
#
# Instrument Type:
# Strictly, the type names should be MinION, GridION or PromethION, if
# they are mixed-case (that's what ONT call them).
#
# Instrument Name:
# These are also the instrument host names for PromethION and GridION
# (they are essentially enhanced Linux boxes). MinIONs are just USB
# devices, so don't have an instrument name as such.
#
# Max Number of Flowcells:
# MinION is always 1.
# GridION is always 5.
# PromethION is 24 or 48, depending on the model. The one we have at the
# moment is 24. (ONT also sell a PromethION P2 with 2 flowcells, but we
# don't have one).
#
# Additional info:
# The flowcells in a GridION are arranged in a row and for customers e.g.
# via the ML warehouse, we address them in sequence 1-5 (i.e. 1-based
# indexing).
#
# The flowcells on a PromethION are arranged in a grid, but we still allow
# addressing them in sequence 1-24 for customers (i.e. 1-based indexing,
# in column-major order).
#
# Here's some of our code for parsing the report JSON generated by
# PromethION runs which shows this explicitly:
# https://github.com/wtsi-npg/valet/blob/devel/valet/report.go
#
# The instrument name for the current GridION is GXB02004 and the current
# PromethION is PC24B148.
#
# MinIONs don't have instrument names because they are just USB devices -
# I haven't seen a MinION run for years, so I'm afraid that I can't tell
# you if there is a logical equivalent that you can use instead.

module Ont
  # Ont::Instrument
  class Instrument < ApplicationRecord
    include Uuidable

    enum :instrument_type, { MinION: 0, GridION: 1, PromethION: 2 }
    validates :name, presence: true, uniqueness: true

    # Returns position names for instrument instance
    def position_names
      POSITION_NAME_MAP[instrument_type]
    end

    # Generates position names for promethION, 1A..1H, 2A..2H, and 3A..3H
    # Returns a hash where keys are position numbers and values are names.
    def self.promethion_position_names
      position_names = (1..3).flat_map do |i|
        ('A'..'H').flat_map do |j|
          "#{i}#{j}"
        end
      end
      position_names.each_with_index.to_h { |v, i| [i + 1, v] }
    end

    # Generates position names for gridION, x1..x5
    # Returns a hash where keys are position numbers and values are names.
    def self.gridion_position_names
      (1..5).index_with { |i| "x#{i}" }
    end

    # Contains position names for instrument_types
    POSITION_NAME_MAP = {
      PromethION: promethion_position_names,
      GridION: gridion_position_names
    }.with_indifferent_access.freeze
  end
end
