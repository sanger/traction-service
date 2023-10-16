# frozen_string_literal: true

# DEPRECATE-Reception-V1:
# Delete this file

class Reception
  # Acts on behalf of a {Reception::ResourceFactory} to handle the creation and validation
  # of individual requests
  class RequestFactory
    include ActiveModel::Model
    extend NestedValidation

    attr_accessor :resource_factory, :reception
    attr_writer :sample, :container

    validates :request, :container, :resource_factory, presence: true
    validates_nested :sample, :container, :request, flatten_keys: false, context: :reception

    delegate :save!, :save, to: :request

    def sample_external_id
      @sample&.fetch(:external_id, nil)
    end

    def tube_barcode
      @container.fetch(:barcode, nil) if tube?
    end

    def plate_barcode
      @container.fetch(:barcode, nil) if well?
    end

    def sample
      resource_factory.sample_for(@sample)
    end

    def container
      resource_factory.container_for(@container)
    end

    def request=(attributes)
      @request_attributes = attributes
    end

    def request
      @request ||= library_type.request_factory(
        reception:,
        sample:,
        container:,
        request_attributes: @request_attributes,
        resource_factory:
      )
    end

    private

    def library_type
      resource_factory.library_type_for(@request_attributes)
    end

    def tube?
      @container[:type] == 'tubes'
    end

    def well?
      @container[:type] == 'wells'
    end
  end
end
