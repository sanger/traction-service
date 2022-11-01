# frozen_string_literal: true

module V1
  # QcResultsUploadResource
  class QcResultsUploadResource < JSONAPI::Resource
    model_name 'QcResultsUpload', add_model_hint: false

    # By default all attributes are assumed to be fetchable.
    attributes :csv_data
  end
end
