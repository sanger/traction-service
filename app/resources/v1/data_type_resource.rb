# frozen_string_literal: true

module V1
  # Exposes valid data type options for use by the UI
  class DataTypeResource < JSONAPI::Resource
    attributes :name, :pipeline, :created_at, :updated_at

    filter :pipeline
  end
end
