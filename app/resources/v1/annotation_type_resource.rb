# frozen_string_literal: true

module V1
  # Provides a JSON:API representation of {AnnotationType} and exposes valid annotation types
  #
  # @note Access this resource via the `/v1/annotation_types` endpoint.
  #
  # For more information about JSON:API see the [JSON:API Specifications](https://jsonapi.org/format/)
  # or look at the [JSONAPI::Resources](http://jsonapi-resources.com/) package for the service
  # implementation of the JSON:API standard.
  #
  # @example
  #   curl -X GET http://localhost:3000/v1/annotation_types
  #   curl -X GET http://localhost:3000/v1/annotation_types/1
  class AnnotationTypeResource < JSONAPI::Resource
    immutable

    # @!attribute [rw] name
    #   @return [String] the name of the annotation type (required, max 50 chars)
    attributes :name
  end
end
