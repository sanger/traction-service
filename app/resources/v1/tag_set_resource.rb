# frozen_string_literal: true

module V1
  # TagResource
  class TagSetResource < JSONAPI::Resource
    attributes :name, :uuid

    has_many :tags
  end
end
