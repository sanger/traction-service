# frozen_string_literal: true

module V1
  # LibraryResource
  class LibraryResource < JSONAPI::Resource
    attributes :state
    has_one :sample, always_include_linkage_data: true
    has_one :tube
  end
end
