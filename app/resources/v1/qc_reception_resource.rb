# frozen_string_literal: true

module V1
  class QcReceptionResource < JSONAPI::Resource
    attributes :qc_results_list, :source

    after_create :publish_messages, :create_qc_results!

    LABWARE_BARCODE = "labware_barcode"
    SAMPLE_EXTEERNAL_ID = "sample_external_id"
    SHEARED_FEMTO_FRAGMENT_SIZE = "sheared_femto_fragment_size"
    POST_SPRI_CONCENTRATION = "post_spri_concentration"
    POST_SPRI_VOLUME = "post_spri_volume"
    FINAL_NANODROP_280 = "final_nano_drop_280"
    FINAL_NANODROP_230 = "final_nano_drop_230"
    FINAL_NANODROP = "final_nano_drop"
    SHEARING_QC_COMMENTS = "shearing_qc_comments"
    DATE_SUBMITTED_UTC = "date_submitted"
    PRIORITY_LEVEL = "priority_level"
    DATE_REQUIRED_BY = "date_required_by"
    REASON_FOR_PRIORITY = "reason_for_priority"

    PERMITTED_QC_FIELDS = [
      LABWARE_BARCODE,
      SAMPLE_EXTEERNAL_ID,
      SHEARED_FEMTO_FRAGMENT_SIZE,
      POST_SPRI_CONCENTRATION,
      POST_SPRI_VOLUME,
      FINAL_NANODROP_280,
      FINAL_NANODROP_230,
      FINAL_NANODROP,
      SHEARING_QC_COMMENTS,
      DATE_SUBMITTED_UTC,
      PRIORITY_LEVEL,
      DATE_REQUIRED_BY,
      REASON_FOR_PRIORITY
    ]

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
