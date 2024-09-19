# frozen_string_literal: true

module V1
  module Pacbio
    # @todo This documentation does not yet include a detailed description of what this resource represents.
    # @todo This documentation does not yet include detailed descriptions for relationships, attributes and filters.
    # @todo This documentation does not yet include any example usage of the API via cURL or similar.
    #
    # @note Access this resource via the `/v1/pacbio/smrt_link_versions/` endpoint.
    #
    # Provides a JSON:API representation of {Pacbio::SmrtLinkVersion}. Returns the SMRT Link
    #  Versions.
    #
    # For more information about JSON:API see the [JSON:API Specifications](https://jsonapi.org/format/)
    # or look at the [JSONAPI::Resources](http://jsonapi-resources.com/) package
    # for the service implementation of the JSON:API standard.
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
