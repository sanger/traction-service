# frozen_string_literal: true

module V1
  # A Reception handles the import of resources into traction
  class ReceptionResource < JSONAPI::Resource
    attributes :source, :plates_attributes, :tubes_attributes

    # When a pool is updated and it is attached to a run we need
    # to republish the messages for the run
    after_create :publish_messages, :construct_resources!

    def fetchable_fields
      [:source]
    end

    private

    def plates_attributes=(plate_parameters)
      raise ArgumentError unless plate_parameters.is_a?(Array)

      @model.plates_attributes = plate_parameters.map do |plate|
        plate.permit(
          :barcode,
          wells_attributes: [
            :position,
            request: permitted_request_attributes,
            sample: permitted_sample_attributes
          ]
        ).to_h.with_indifferent_access
      end
    end

    def tubes_attributes=(tube_parameters)
      raise ArgumentError unless tube_parameters.is_a?(Array)

      @model.tubes_attributes = tube_parameters.map do |tube|
        tube.permit(
          :barcode,
          request: permitted_request_attributes,
          sample: permitted_sample_attributes
        ).to_h.with_indifferent_access
      end
    end

    def construct_resources!
      @model.construct_resources!
    end

    def permitted_request_attributes
      [*::Pacbio.request_attributes, *::Ont.request_attributes, *::Saphyr.request_attributes].uniq
    end

    def permitted_sample_attributes
      %i[name external_id species study_uuid priority_level
          sanger_sample_id supplier_name taxon_id donor_id country_of_origin
          accession_number date_of_sample_collection]
    end

    def publish_messages
      # Publish message for the sample table
      publish_message(
        @model.requests.map(&:sample),
        Pipelines.reception.sample.message
      )
      # Publish message for the stock_resource table
      publish_message(
        @model.requests,
        Pipelines.reception.stock_resource.message
      )
    end

    def publish_message(message, config)
      Messages.publish(message, config)
    end
  end
end
