# frozen_string_literal: true

module V1
  module Pacbio
    # RequestResource
    class RequestResource < JSONAPI::Resource
      include Pipelines::Requestor::Resource
    end
  end
end
