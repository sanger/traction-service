# frozen_string_literal: true

module V1
  # QcReceptionResource

  # Steps:
  # 1. Create QcReception
  # 2. Create QcResults
  # 3. Publish qc result messages
  class QcReceptionResource < JSONAPI::Resource
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

    def create_qc_results!
      @model.create_qc_results!
    end

    def publish_messages
      Messages.publish(@model.messages, Pipelines.qc_result.qc_reception_message)
    end

    def permitted_attributes
      PERMITTED_QC_FIELDS
    end
  end
end
