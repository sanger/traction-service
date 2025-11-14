# frozen_string_literal: true

module V1
  module Pacbio
    # Provides a JSON:API representation of {Pacbio::SmrtLinkOptionVersion}.
    #
    # Each SMRT link version can have multiple options.
    # Each SMRT Link Option can belong to multiple versions.
    #
    ## Primary relationships:
    # * smrt_link_option {V1::Pacbio::SmrtLinkOptionResource} - The SMRT Link
    #   option associated with this version.
    #
    # @note Access this resource via the `/v1/pacbio/smrt_link_option_versions/` endpoint.
    #
    # @example
    #   curl -X GET http://localhost:3100/v1/pacbio/smrt_link_versions/1?include=smrt_link_option_versions
    #
    class SmrtLinkOptionVersionResource < JSONAPI::Resource
      model_name 'Pacbio::SmrtLinkOptionVersion'

      has_one :smrt_link_option
      has_one :smrt_link_version
    end
  end
end
