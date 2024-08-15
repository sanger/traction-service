# frozen_string_literal: true

module V1
  module Pacbio
    # @todo This documentation does not yet include a detailed description of what this resource represents.
    # @todo This documentation does not yet include detailed descriptions for relationships, attributes and filters.
    # @todo This documentation does not yet include any example usage of the API via cURL or similar.
    #
    # @note Access this resource via the `/v1/pacbio/smrt_link_option_versions/` endpoint.
    #
    # Provides a JSON:API representation of {Pacbio::SmrtLinkOptionVersion}.
    # Each SMRT link version can have multiple options.
    #  Each SMRT Link Option can belong to multiple versions.
    #
    # For more information about JSON:API see the [JSON:API Specifications](https://jsonapi.org/format/)
    # or look at the [JSONAPI::Resources](http://jsonapi-resources.com/) package
    # for the service implementation of the JSON:API standard.
    # SmrtLinkOptionVersionResource - each SMRT link version can have multiple options
    # Each SMRT Linke Option can belong to multiple versions
    class SmrtLinkOptionVersionResource < JSONAPI::Resource
      model_name 'Pacbio::SmrtLinkOptionVersion'

      has_one :smrt_link_option
      has_one :smrt_link_version
    end
  end
end
