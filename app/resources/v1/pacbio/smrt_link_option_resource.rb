# frozen_string_literal: true

module V1
  module Pacbio
    # @todo This documentation does not yet include a detailed description of what this resource represents.
    # @todo This documentation does not yet include detailed descriptions for relationships, attributes and filters.
    # @todo This documentation does not yet include any example usage of the API via cURL or similar.
    #
    # @note Access this resource via the `/v1/pacbio/smrt_link_options/` endpoint.
    #
    # Provides a JSON:API representation of {Pacbio::SmrtLinkOption}.
    # This is a resource to return the SMRT link  options for a particular SMRT Link version.
    #
    # For more information about JSON:API see the [JSON:API Specifications](https://jsonapi.org/format/)
    # or look at the [JSONAPI::Resources](http://jsonapi-resources.com/) package
    # for the service implementation of the JSON:API standard.
    class SmrtLinkOptionResource < JSONAPI::Resource
      model_name 'Pacbio::SmrtLinkOption'

      # @!attribute [rw] key
      #   @return [String] the key of the SMRT link option
      # @!attribute [rw] label
      #   @return [String] the label of the SMRT link option
      # @!attribute [rw] default_value
      #   @return [String] the default value of the SMRT link option
      # @!attribute [rw] data_type
      #   @return [String] the data type of the SMRT link option
      # @!attribute [rw] select_options
      #   @return [Array<String>] the select options for the SMRT link option
      attributes :key, :label, :default_value, :data_type, :select_options
    end
  end
end
