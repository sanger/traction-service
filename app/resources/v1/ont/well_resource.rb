# frozen_string_literal: true

module V1
  module Ont
    # Provides a JSON:API representation of {Ont::Well}
    #
    # @note This resource cannot be accessed via the `/v1/ont/wells/` endpoint.
    # It is accessible via the nested route under {Ont::Plate} using includes.
    #
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
