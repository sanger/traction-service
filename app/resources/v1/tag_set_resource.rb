# frozen_string_literal: true

module V1
  # TagSetResource
  class TagSetResource < JSONAPI::Resource
    attributes :name, :uuid, :pipeline

    has_many :tags

    filter :pipeline

    def self.records(options = {})
      super.where(active: true)
    end
  end
end
