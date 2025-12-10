# frozen_string_literal: true

module V1
  module Ont
    # Provides a JSON:API representation of {Ont::Instrument}.
    #
    # @note Access this resource via the `/v1/ont/instruments/` endpoint.
    #
    # @example
    #   curl -X GET http://localhost:3100/v1/ont/instruments
    #   curl -X GET "http://localhost:3100/v1/ont/instruments/1"
    #
    class InstrumentResource < JSONAPI::Resource
      model_name 'Ont::Instrument'

      # @!attribute [rw] name
      #   @return [String] the name of the instrument
      # @!attribute [rw] instrument_type
      #   @return [String] the type of the instrument
      # @!attribute [rw] max_number_of_flowcells
      #   @return [Integer] the maximum number of flowcells the instrument can handle
      attributes :name, :instrument_type, :max_number_of_flowcells
    end
  end
end
