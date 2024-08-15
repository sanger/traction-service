# frozen_string_literal: true

module V1
  module Ont
    # @todo This documentation does not yet include a detailed description of what this resource represents.
    # @todo This documentation does not yet include detailed descriptions for relationships, attributes and filters.
    # @todo This documentation does not yet include any example usage of the API via cURL or similar.
    #
    # @note Access this resource via the `/v1/ont/tube/` endpoint.
    #
    # Provides a JSON:API representation of {Well}. This is resource to return the wells for an ONT
    #  plate.
    #
    # For more information about JSON:API see the [JSON:API Specifications](https://jsonapi.org/format/)
    # or look at the [JSONAPI::Resources](http://jsonapi-resources.com/) package
    # for the service implementation of the JSON:API standard.
    class WellResource < JSONAPI::Resource
      model_name '::Well'

      # @!attribute [rw] position
      #   @return [String] the position of the well
      attributes :position

      has_many :materials, class_name: 'ContainerMaterial', relation_name: :container_materials,
                           foreign_key_on: :related

      has_many :requests, class_name: 'Request', relation_name: :ont_requests,
                          foreign_key_on: :related
      has_one :plate, relation_name: :plate
    end
  end
end
