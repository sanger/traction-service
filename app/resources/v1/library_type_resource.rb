# frozen_string_literal: true

module V1
  # Exposes valid library type options for use by the UI
  class LibraryTypeResource < JSONAPI::Resource
    attributes :name, :pipeline, :created_at, :updated_at, :external_identifier, :active

    filter :pipeline
    filter :active, default: true
  end
end
