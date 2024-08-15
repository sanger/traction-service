# frozen_string_literal: true

module V1
  module Saphyr
    # @todo This documentation does not yet include a detailed description of what this resource represents.
    # @todo This documentation does not yet include detailed descriptions for relationships, attributes and filters.
    # @todo This documentation does not yet include any example usage of the API via cURL or similar.
    #
    # @note Access this resource via the `/v1/saphyr/chip/` endpoint.
    #
    # Provides a JSON:API representation of {Saphyr::Chip}.
    #
    # For more information about JSON:API see the [JSON:API Specifications](https://jsonapi.org/format/)
    # or look at the [JSONAPI::Resources](http://jsonapi-resources.com/) package
    # for the service implementation of the JSON:API standard.
    class ChipResource < JSONAPI::Resource
      model_name 'Saphyr::Chip'

      # @!attribute [rw] barcode
      #   @return [String] the barcode of the chip
      attributes :barcode

      has_many :flowcells, foreign_key_on: :related
    end
  end
end
