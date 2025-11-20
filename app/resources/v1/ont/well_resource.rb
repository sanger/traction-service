# frozen_string_literal: true

module V1
  module Ont
    # Provides a JSON:API representation of {Ont::Well}
    #
    # This is resource to return the wells for an ONT plate.
    #
    ## Primary relationships:
    # * materials {V1::Ont::ContainerMaterialResource} - The materials contained in the well
    # * requests {V1::Ont::RequestResource} - The ONT requests associated with the well
    # * plate {V1::Ont::PlateResource} - The plate to which the well belongs
    #
    # @note Access this resource via the `/v1/ont/wells/` endpoint.
    #
    # @aexample
    #  curl -X GET "http://localhost:3100/v1/ont/plates?filter[barcode]=GEN-1762592713-1&include=wells,wells.requests"
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
