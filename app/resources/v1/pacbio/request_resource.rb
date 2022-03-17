# frozen_string_literal: true

module V1
  module Pacbio
    # RequestResource
    class RequestResource < JSONAPI::Resource
      include Pipelines::Requestor::Resource

      has_one :well
      has_one :plate
      has_one :tube
    end
  end
end
