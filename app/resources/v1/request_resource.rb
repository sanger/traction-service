# frozen_string_literal: true

module V1
  # `RequestResource` Provides a JSON:API representation of {Request} and exposes valid request
  # for use by the UI.
  #
  # Request resource represents a unit of work associated with a specific sample,
  # requestable (polymorphic), and optionally a reception.
  #
  # @note Access this resource via the `/v1/requests` endpoint.
  #
  # ## Attributes
  # * id
  # * sample_id
  # * requestable_id
  # * requestable_type
  # * reception_id
  # * created_at
  # * updated_at

  # ## Relationships
  # * sample
  # * requestable (polymorphic)
  # * reception

  # For more information about JSON:API see the [JSON:API Specifications](https://jsonapi.org/format/)
  # or look at the [JSONAPI::Resources](http://jsonapi-resources.com/) package for the service
  # implementation of the JSON:API standard.
  class RequestResource < JSONAPI::Resource
  end
end
