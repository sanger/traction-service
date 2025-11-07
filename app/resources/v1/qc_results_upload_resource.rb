# frozen_string_literal: true

module V1
  # Provides a JSON:API representation of {QcResultsUpload} model.
  #
  # QcResultsUploadResource resource handles the uploading of QC results via CSV data.
  # Steps:<br>
  #
  # 1. Validate QcResultsUpload data (via QcResultsUploadFactory validation)
  # 2. Create QcResultsUpload entity
  # 3. Create QcDecisions, QcResults, QcDecisionResult entities
  # 4. Build QcResultMessages
  # 5. Publish QcResultMessages
  #
  # @example
  #
  # @todo CURL NEEDS ESCAPING THE CSV PROPERLY
  #
  # @note Access this resource via the `/v1/qc_results` endpoint.
  #
  #
  class QcResultsUploadResource < JSONAPI::Resource
    model_name 'QcResultsUpload', add_model_hint: false

    # @!attribute [w] csv_data
    #   @return [String] the CSV data for the QC results upload
    # @!attribute [w] used_by
    #   @return [String] the user who uploaded the QC results
    attributes :csv_data, :used_by

    # create_entities! needs to be called before publish_messages
    # which requires the after_create to be ordered this way
    after_create :publish_messages, :create_entities!

    delegate :create_entities!, to: :@model

    def publish_messages
      Messages.publish(@model.messages, Pipelines.qc_result.message)
    end
  end
end
