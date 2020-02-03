# frozen_string_literal: true

module V1
  # TagSetResource
  class TagSetResource < JSONAPI::Resource
    attributes :name, :uuid

    has_many :tags
  end
end
