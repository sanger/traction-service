# frozen_string_literal: true

module V1
  # FlowcellResource
  class FlowcellResource < JSONAPI::Resource
    attributes :position

    has_one :library, foreign_key_on: :related
  end
end
