# frozen_string_literal: true

module V1
  # QcResultsUploadResource
  class QcResultsUploadResource < JSONAPI::Resource
    model_name 'QcResultsUpload', add_model_hint: false

    attributes :csv_data, :used_by

    after_create :create_entities!

    def create_entities!
      @model.create_entities!
    end
  end
end
