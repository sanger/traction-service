# frozen_string_literal: true

module V1
  module Pacbio
    # PlatesController
    class PlatesController < ApplicationController
      # This endpoint is not strictly JSON API compliant:
      # https://jsonapi.org/format/#crud-creating
      #   A resource can be created by sending a POST request to a URL that represents a collection
      #   of resources. The request MUST include a single resource object as primary data. The
      #   resource object MUST contain at least a type member.
      #
      # Here we may return multiple plates. To be compliant I think it would need to return a
      # plate_collection (or similar), but it doesn't sound like we'd need to provide an id.
    end
  end
end
