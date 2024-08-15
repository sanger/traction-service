# frozen_string_literal: true

module V1
  module Saphyr
    # @todo This documentation does not yet include a detailed description of what this resource represents.
    # @todo This documentation does not yet include detailed descriptions for relationships, attributes and filters.
    # @todo This documentation does not yet include any example usage of the API via cURL or similar.
    #
    # @note Access this resource via the `/v1/saphyr/flowcell/` endpoint.
    #
    # Provides a JSON:API representation of {Saphyr::Flowcell}.
    #
    # For more information about JSON:API see the [JSON:API Specifications](https://jsonapi.org/format/)
    # or look at the [JSONAPI::Resources](http://jsonapi-resources.com/) package
    # for the service implementation of the JSON:API standard.
    class FlowcellResource < JSONAPI::Resource
      model_name 'Saphyr::Flowcell'

      # @!attribute [rw] position
      #   @return [String] the position of the flowcell
      attributes :position

      has_one :library, foreign_key_on: :related
    end
  end
end
