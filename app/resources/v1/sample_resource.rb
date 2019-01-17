# frozen_string_literal: true

module V1
  # SampleResource
  class SampleResource < JSONAPI::Resource
    attributes :name, :state, :sequencescape_request_id, :species
  end
end
