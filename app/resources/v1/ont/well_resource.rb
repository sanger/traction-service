# frozen_string_literal: true

module V1
    module Ont
      class WellResource < JSONAPI::Resource
        model_name '::Well'
  
        attributes :position
  
        has_many :materials, class_name: 'ContainerMaterial', relation_name: :container_materials,
                             foreign_key_on: :related
  
        has_many :requests, relation_name: :ont_requests
        has_one :plate, relation_name: :plate
      end
    end
  end