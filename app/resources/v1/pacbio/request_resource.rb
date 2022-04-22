# frozen_string_literal: true

module V1
  module Pacbio
    # RequestResource
    class RequestResource < JSONAPI::Resource
      model_name 'Pacbio::Request', add_model_hint: false

      attributes(*::Pacbio.request_attributes, :sample_name, :barcode, :sample_species,
                 :created_at, :source_identifier)

      has_one :well
      has_one :plate
      has_one :tube

      # When a request is updated and it is attached to a run we need
      # to resend the data to the warehouse
      after_update :publish_messages

      def barcode
        @model&.tube&.barcode
      end

      def created_at
        @model.created_at.to_s(:us)
      end

      def self.records_for_populate(*_args)
        super.preload(:sample, :tube, well: :plate)
      end

      def publish_messages
        Messages.publish(@model.sequencing_plates, Pipelines.pacbio.message)
      end
    end
  end
end
