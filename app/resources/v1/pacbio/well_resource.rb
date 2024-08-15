# frozen_string_literal: true

module V1
  module Pacbio
    # @todo This documentation does not yet include a detailed description of what this resource represents.
    # @todo This documentation does not yet include detailed descriptions for relationships, attributes and filters.
    # @todo This documentation does not yet include any example usage of the API via cURL or similar.
    #
    # @note Access this resource via the `/v1/pacbio/wells/` endpoint.
    #
    # Provides a JSON:API representation of {Well}. Returns the wells for a Pacbio plate.
    #
    # For more information about JSON:API see the [JSON:API Specifications](https://jsonapi.org/format/)
    # or look at the [JSONAPI::Resources](http://jsonapi-resources.com/) package
    # for the service implementation of the JSON:API standard.
    class WellResource < JSONAPI::Resource
      model_name '::Well'

      # @!attribute [rw] position
      #   @return [String] the position of the well
      attributes :position

      # TODO: to fit in with what is currently here we are returning materials which could either
      # be request or library
      # also the container material could have a container which is a tube
      # this means we are returning attributes which don't make sense e.g. barcode
      # We really want to be returning them as samples
      has_many :materials, class_name: 'ContainerMaterial', relation_name: :container_materials,
                           foreign_key_on: :related

      has_many :requests, relation_name: :pacbio_requests
      has_one :plate, relation_name: :plate
    end
  end
end
