# frozen_string_literal: true

module V1
  module Ont
    # rubocop:disable Layout/LineLength
    # Provides a JSON:API representation of {Ont::Instrument}.
    #
    # ONT Instruments are devices used for DNA or RNA sequencing by Oxford
    # Nanopore Technologies (ONT). They use the same nanopore sequencing
    # technology but differ in scale and throughput. The main difference is
    # the number of flowcells they can run.
    #
    # @note This resource is immutable: its endpoint will not accept `POST`, `PATCH`, or `DELETE` requests.
    # @note Access this resource via the `/v1/ont/instruments/` endpoint.
    #
    # @example GET request to list all ONT instruments
    #   curl -X GET http://localhost:3100/v1/ont/instruments
    #
    # @example GET request to retrieve a specific ONT instrument by ID
    #  curl -X GET "http://localhost:3100/v1/ont/instruments/1"
    #
    # For more information about JSON:API see the [JSON:API Specifications](https://jsonapi.org/format/)
    # or look at the [JSONAPI::Resources](http://jsonapi-resources.com/) package
    # for the service implementation of the JSON:API standard.
    # rubocop:enable Layout/LineLength
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
