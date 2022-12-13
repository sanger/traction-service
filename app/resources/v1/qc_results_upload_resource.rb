# frozen_string_literal: true

module V1
  # QcResultsUploadResource

  # Steps:
  # 1. Validate QcResultsUpload data (via QcResultsUploadFactory validation)
  # 2. Create QcResultsUpload entity
  # 3. Create QcDecisions, QcResults, QcDecisionResult entities
  # 4. Build QcResultMessages
  # 5. Publish QcResultMessages
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
