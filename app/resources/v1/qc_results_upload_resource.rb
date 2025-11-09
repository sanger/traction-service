# frozen_string_literal: true

module V1
  # rubocop:disable Layout/LineLength
  # Provides a JSON:API representation of {QcResultsUpload} model.
  #
  # QcResultsUploadResource resource handles the uploading of QC results via CSV data.
  #
  # Steps:
  #
  # 1. Validate QcResultsUpload data (via QcResultsUploadFactory validation)
  # 2. Create QcResultsUpload entity
  # 3. Create QcDecisions, QcResults, QcDecisionResult entities
  # 4. Build QcResultMessages
  # 5. Publish QcResultMessages
  #
  # @note This resource is write-only: its endpoint will not accept `GET`, `PATCH`, or `DELETE` requests.
  # @note Access this resource via the `/v1/qc_results_uploads` endpoint.
  #
  # @example POST request to upload QC results via CSV data
  #    csv_data=$(jq -Rs . qc_results.csv)
  #    curl -X POST http://localhost:3100/v1/qc_results_uploads \
  #      -H "Content-Type: application/vnd.api+json" \
  #      -H "Accept: application/vnd.api+json" \
  #      -d '{
  #        "data": {
  #          "type": "qc_results_uploads",
  #          "attributes": {
  #            "csv_data": '"${csv_data}"',
  #            "used_by": "extraction"
  #          }
  #        }
  #      }'
  #
  # For more information about JSON:API see the [JSON:API Specifications](https://jsonapi.org/format/)
  # or look at the [JSONAPI::Resources](http://jsonapi-resources.com/) package for the service
  # implementation of the JSON:API standard.
  # rubocop:enable Layout/LineLength
  class QcResultsUploadResource < JSONAPI::Resource
    model_name 'QcResultsUpload', add_model_hint: false

    # @!attribute [w] csv_data
    #   @return [String] the CSV data for the QC results upload
    # @!attribute [w] used_by
    #   @return [String] the process or system that uploaded the QC results
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
