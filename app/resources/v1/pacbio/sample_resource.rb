# frozen_string_literal: true

module V1
  module Pacbio
    # Provides a JSON:API representation of {Pacbio::Sample}
    # It inherits all attributes, date formatting, and behavior from
    # `V1::SampleResource` without modification.
    #
    # @note Access this resource via the `/v1/pacbio/samples/` endpoint.
    #
    # For more information about JSON:API see the [JSON:API Specifications](https://jsonapi.org/format/)
    # or look at the [JSONAPI::Resources](http://jsonapi-resources.com/) package
    # for the service implementation of the JSON:API standard.
    class SampleResource < V1::SampleResource
    end
  end
end
