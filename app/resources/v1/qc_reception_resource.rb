# frozen_string_literal: true

module V1
  # rubocop:disable Layout/LineLength
  # Provides a JSON:API representation of {QcReception} model.
  #
  # A QcReception makes an entry in qc_receptions for all the requests
  # received TOL consumer on the qc_reception endpoint.
  # Stores the qc data in qc_results table with the associated qc_reception_id
  #
  # Steps:
  #
  # 1. Create QcReception
  # 2. Create QcResults
  # 3. Publish qc result messages
  #
  # @note This resource is write-only: its endpoint will not accept `GET`, `PATCH`, or `DELETE` requests.
  # @note Access this resource via the `/v1/qc_receptions` endpoint.
  #
  # @example POST request to create a new QC reception with QC results
  #
  #   curl -X POST "http://localhost:3100/v1/qc_receptions" \
  #     -H "Content-Type: application/vnd.api+json" \
  #     -H "Accept: application/vnd.api+json" \
  #     -d '{
  #       "data": {
  #         "type": "qc_receptions",
  #         "attributes": {
  #           "source": "tol-lab-share.tol",
  #           "qc_results_list": [
  #             {
  #               "final_nano_drop": "200",
  #               "final_nano_drop_230": "230",
  #               "post_spri_concentration": "10",
  #               "final_nano_drop_280": "280",
  #               "post_spri_volume": "20",
  #               "sheared_femto_fragment_size": "5",
  #               "shearing_qc_comments": "Comments",
  #               "labware_barcode": "FD20706500",
  #               "sample_external_id": "supplier_sample_name_DDD"
  #             }
  #           ]
  #         }
  #       }
  #     }'
  #
  # For more information about JSON:API see the [JSON:API Specifications](https://jsonapi.org/format/)
  # or look at the [JSONAPI::Resources](http://jsonapi-resources.com/) package for the service
  # implementation of the JSON:API standard.
  # rubocop:enable Layout/LineLength
  class QcReceptionResource < JSONAPI::Resource
    # @!attribute [w] qc_results_list
    #   @return [Array<Hash>] the list of QC results
    # @!attribute [w] source
    #   @return [String] the source of the QC reception
    # @!method qc_results_list=(request_parameters)
    #   Sets the QC results list from the request parameters.
    #   @param [Array<Hash>] request_parameters the request parameters for QC results
    #   @raise [ArgumentError] if the request parameters are not an array
    # @!method create_qc_results!
    #   Creates QC results for the model.
    # @!method publish_messages
    #   Publishes messages for the QC reception.
    # @!method permitted_attributes
    #   Returns the list of permitted QC fields.
    #   @return [Array<String>] the list of permitted QC fields
    attributes :qc_results_list, :source

    # The after_create happens in a transaction, and since there are
    # multiple callbacks, they are executed is reverse order.
    # create_qc_results! is executed first, followed by publish_messages
    after_create :publish_messages, :create_qc_results!

    PERMITTED_QC_FIELDS = %w[
      labware_barcode
      sample_external_id
      sheared_femto_fragment_size
      post_spri_concentration
      post_spri_volume
      final_nano_drop_280
      final_nano_drop_230
      final_nano_drop
      shearing_qc_comments
      date_submitted
    ].freeze

    def qc_results_list=(request_parameters)
      raise ArgumentError unless request_parameters.is_a?(Array)

      @model.qc_results_list = request_parameters.map do |request|
        request.permit(permitted_attributes).to_h
      end
    end

    delegate :create_qc_results!, to: :@model

    def publish_messages
      Messages.publish(@model.messages, Pipelines.qc_result.qc_reception_message)
    end

    def permitted_attributes
      PERMITTED_QC_FIELDS
    end
  end
end
