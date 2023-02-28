# frozen_string_literal: true

module V1
  # A Reception handles the import of resources into traction
  class ReceptionResource < JSONAPI::Resource
    attributes :request_attributes, :source

    # When a pool is updated and it is attached to a run we need
    # to republish the messages for the run
    after_create :construct_resources!

    def fetchable_fields
      [:source]
    end

    private

    def request_attributes=(request_parameters)
      raise ArgumentError unless request_parameters.is_a?(Array)

      @model.request_attributes = request_parameters.map do |request|
        request.permit(request: permitted_request_attributes,
                       sample: %i[name external_id species study_uuid],
                       container: %i[type barcode position])
               .to_h
               .with_indifferent_access
      end
    end

    def construct_resources!
      @model.construct_resources!
      publish_messages
    end

    def permitted_request_attributes
      [*::Pacbio.request_attributes, *::Ont.request_attributes, *::Saphyr.request_attributes].uniq
    end

    def publish_messages
      Messages.publish(
        @model.requests.map(&:sample),
        Pipelines.reception.sample.message
      )
      Messages.publish(
        @model.requests,
        Pipelines.reception.stock_resource.message
      )
    end
  end
end
