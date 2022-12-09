# frozen_string_literal: true

module V1
  # QcResultsUploadResource
  class QcResultsUploadResource < JSONAPI::Resource
    model_name 'QcResultsUpload', add_model_hint: false

    attributes :csv_data, :used_by

    after_create :create_entities!, :publish_messages

    def create_entities!
      @model.create_entities!
    end

    def publish_messages
      Messages.publish(@model.messages, Pipelines.qc_result.message)
    end
  end
end
