# frozen_string_literal: true

module V1
  module Pacbio
    # Provides a JSON:API representation of {Tube}.
    #
    ## Filters:
    # * barcode
    #
    ## Primary relationships:
    # * materials {V1::Pacbio::ContainerMaterialResource}
    # * pools {V1::Pacbio::PoolResource}
    # * library {V1::Pacbio::LibraryResource}
    # * requests {V1::Pacbio::RequestResource}
    #
    # @note Access this resource via the `/v1/pacbio/tubes/` endpoint.
    #
    # @example
    #  curl -X GET http://localhost:3100/v1/pacbio/tubes/
    #  curl -X GET http://localhost:3100/v1/pacbio/tubes?filter[barcode]=GEN-1762592703-6"
    #  curl -X GET http://localhost:3100/v1/pacbio/tubes?filter[barcode]=GEN-1762592703-6&include=materials,pools,libraries,requests
    #  curl -X GET http://localhost:3100/v1/pacbio/tubes?&filter[barcode]=TRAC-2-20172&include=pools.libraries.request,pools.requests,pools.used_aliquots.tag,libraries.used_aliquots.request,libraries.used_aliquots.tag&fields[requests]=sample_name&fields[tags]=group_id
    #
    class TubeResource < JSONAPI::Resource
      model_name 'Tube'

      # @!attribute [rw] barcode
      #   @return [String] the barcode of the tube
      attributes :barcode
      has_many :materials, class_name: 'ContainerMaterial', relation_name: :container_materials,
                           foreign_key_on: :related
      has_many :pools, relation_name: :pacbio_pools, class_name: 'Pool'
      # libraries has been used as opposed to library as the json api
      # resources relationship was breaking
      has_one :libraries, relation_name: :pacbio_library, class_name: 'Library'
      has_many :requests, relation_name: :pacbio_requests

      # Filters
      filter :barcode, apply: ->(records, value, _options) { records.by_barcode(value) }

      def self.records(_options = {})
        ::Tube.by_pipeline(:pacbio)
      end
    end
  end
end
