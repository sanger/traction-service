# frozen_string_literal: true

module V1
  #
  # @note This endpoint can't be directly accessed via the `/v1/used_bys/` endpoint
  # @note `UsedByResource` supports aliquot polymorphism
  #
  class UsedByResource < JSONAPI::Resource
  end
end
