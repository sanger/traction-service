# frozen_string_literal: true

module V1
  module Ont
    # @todo This documentation does not yet include a detailed description of what this resource represents.
    # @todo This documentation does not yet include detailed descriptions for relationships, attributes and filters.
    # @todo This documentation does not yet include any example usage of the API via cURL or similar.
    #
    # @note Access this resource via the `/v1/ont/instrument/` endpoint.
    #
    # Provides a JSON:API representation of {Ont::Instrument}.
    #
    # For more information about JSON:API see the [JSON:API Specifications](https://jsonapi.org/format/)
    # or look at the [JSONAPI::Resources](http://jsonapi-resources.com/) package
    # for the service implementation of the JSON:API standard.
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
