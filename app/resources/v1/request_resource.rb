# frozen_string_literal: true

module V1
  # RequestResource
  class RequestResource < JSONAPI::Resource
    include Pipelines::Requestor::Resource
  end
end
