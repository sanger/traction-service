# frozen_string_literal: true

module V1
  module Ont
    # Provides a JSON:API representation of {Ont::Instrument}.
    #
    # ONT Instruments are devices used for DNA or RNA sequencing by Oxford
    # Nanopore Technologies (ONT). They use the same nanopore sequencing
    # technology but differ in scale and throughput. The main difference is
    # the number of flowcells they can run.
    #
    # @note Access this resource via the `/v1/ont/instruments/` endpoint.
    #
    # @example
    #   curl -X GET http://localhost:3100/v1/ont/instruments
    #   curl -X GET "http://localhost:3100/v1/ont/instruments/1"
    #
    class InstrumentResource < JSONAPI::Resource
      model_name 'Ont::Instrument'

      # @!attribute [r] name
      #   @return [String] the name of the instrument
      # @!attribute [r] instrument_type
      #   @return [String] the type of the instrument
      # @!attribute [r] max_number_of_flowcells
      #   @return [Integer] the maximum number of flowcells the instrument can handle
      attributes :name, :instrument_type, :max_number_of_flowcells
    end
  end
end
