# frozen_string_literal: true

module V1
  module Pacbio
    # WellResource - returns the wells for a Pacbio plate
    class WellResource < JSONAPI::Resource
      model_name '::Well'

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
