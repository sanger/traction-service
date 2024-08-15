# frozen_string_literal: true

module V1
  # @todo This documentation does not yet include a detailed description of what this resource represents.
  # @todo This documentation does not yet include detailed descriptions for relationships, attributes and filters.
  # @todo This documentation does not yet include any example usage of the API via cURL or similar.
  #
  # @note Access this resource via the `/v1/qc_result` endpoint.
  #
  # Steps:<br>
  #
  # 1. Validate QcResultsUpload data (via QcResultsUploadFactory validation)
  # 2. Create QcResultsUpload entity
  # 3. Create QcDecisions, QcResults, QcDecisionResult entities
  # 4. Build QcResultMessages
  # 5. Publish QcResultMessages
  #
  # For more information about JSON:API see the [JSON:API Specifications](https://jsonapi.org/format/)
  # or look at the [JSONAPI::Resources](http://jsonapi-resources.com/) package for the service
  # implementation of the JSON:API standard.
  class QcResultsUploadResource < JSONAPI::Resource
    model_name 'QcResultsUpload', add_model_hint: false

    # @!attribute [rw] csv_data
    #   @return [String] the CSV data for the QC results upload
    # @!attribute [rw] used_by
    #   @return [String] the user who uploaded the QC results
    attributes :csv_data, :used_by

    # create_entities! needs to be called before publish_messages
    # which requires the after_create to be ordered this way
    after_create :publish_messages, :create_entities!

    def create_entities!
      @model.create_entities!
    end

    def publish_messages
      Messages.publish(@model.messages, Pipelines.qc_result.message)
    end
  end
end
