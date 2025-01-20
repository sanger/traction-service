# frozen_string_literal: true

module V1
  module Pacbio
    # Provides a JSON:API representation of {Pacbio::Well}.
    #
    # This resource is primarily accessed through {V1::Pacbio::RunResource}
    # and {V1::Pacbio::PlateResource}.
    # Wells are primarily created via a Run and Plate.
    #
    # For more information about JSON:API see the [JSON:API Specifications](https://jsonapi.org/format/)
    # or look at the [JSONAPI::Resources](http://jsonapi-resources.com/) package
    # for the service implementation of the JSON:API standard.
    #
    # This resource represents a Pacbio Well and can return all wells or a single well
    #
    # This resource has no filters.
    #
    # ## Primary relationships:
    #
    # * materials {V1::Pacbio::MaterialResource}
    # * requests {V1::Pacbio::RequestResource}
    # * plate {V1::Pacbio::PlateResource}
    #
    # @note Access this resource via the `/v1/pacbio/wells/` endpoint.
    #
    # @example
    #   curl -X GET http://localhost:3000/v1/pacbio/wells/1
    #   curl -X GET http://localhost:3000/v1/pacbio/wells
    #   curl -X GET http://localhost:3000/v1/pacbio/runs/1/wells
    #   curl -X GET http://localhost:3000/v1/pacbio/runs/1/wells/1
    #
    #   https://localhost:3000/v1/pacbio/v1/wells/1?include=plate,materials
    #
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
