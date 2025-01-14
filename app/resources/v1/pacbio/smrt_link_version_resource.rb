# frozen_string_literal: true

module V1
  module Pacbio
    # The JSON:API representation of a {Pacbio::SmrtLinkVersion}.
    # For more information about JSON:API see the [JSON:API Specifications](https://jsonapi.org/format/)
    # or look at the [JSONAPI::Resources](http://jsonapi-resources.com/) package
    # for the service implementation of the JSON:API standard.
    #
    # @note Access this resource via the `/v1/pacbio/smrt_link_versions/` endpoint.
    #
    # This resource represents a Pacbio SmrtLinkVersion and can return all smrt_link_versions
    # or a single smrt_link_version
    #
    # This resource has no filters.
    #
    # ## Primary relationships:
    #
    # * smrt_link_option_versions {V1::Pacbio::SmrtLinkOptionVersionResource}
    #
    # @example
    #   curl -X GET http://localhost:3000/v1/pacbio/smrt_link_versions/1
    #   curl -X GET http://localhost:3000/v1/pacbio/smrt_link_versions
    #
    #  https://localhost:3000/v1/pacbio/v1/smrt_link_versions/1?include=smrt_link_option_versions
    #
    class SmrtLinkVersionResource < JSONAPI::Resource
      model_name 'Pacbio::SmrtLinkVersion'

      # @!attribute [rw] name
      #   @return [String] the name of the SMRT Link version
      # @!attribute [rw] default
      #   @return [Boolean] whether the SMRT Link version is the default
      # @!attribute [rw] active
      #   @return [Boolean] whether the SMRT Link version is active
      attributes :name, :default, :active

      has_many :smrt_link_option_versions, class_name: 'SmrtLinkOptionVersion'
    end
  end
end
