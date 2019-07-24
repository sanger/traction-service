# frozen_string_literal: true

module V1
  # MaterialResource
  class RequestResource < JSONAPI::Resource
    include Pipelines::Requestor::Resource
  end
end
