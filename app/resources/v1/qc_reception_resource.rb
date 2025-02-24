# frozen_string_literal: true

module V1
  # @todo This documentation does not yet include a detailed description of what this resource represents.
  # @todo This documentation does not yet include detailed descriptions for relationships, attributes and filters.
  # @todo This documentation does not yet include any example usage of the API via cURL or similar.
  #
  # @note Access this resource via the `/v1/qc_receptions` endpoint.
  #
  # Provides a JSON:API representation of {QcReception}.
  #
  # Steps:
  #
  # 1. Create QcReception
  # 2. Create QcResults
  # 3. Publish qc result messages
  #
  # For more information about JSON:API see the [JSON:API Specifications](https://jsonapi.org/format/)
  # or look at the [JSONAPI::Resources](http://jsonapi-resources.com/) package for the service
  # implementation of the JSON:API standard.
  class QcReceptionResource < JSONAPI::Resource
    # @!attribute [rw] qc_results_list
    #   @return [Array<Hash>] the list of QC results
    # @!attribute [rw] source
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
