# frozen_string_literal: true

# Ont namespace
module Ont
  # RequestFactory
  # The factory will build a request and associated sample
  # from the input attributes
  class RequestFactory
    include ActiveModel::Model

    validate :check_request

    def initialize(attributes = {})
      @well = attributes[:well]
      return unless attributes.key?(:request_attributes)

      build_request(attributes[:request_attributes])
    end

    attr_reader :request

    def save
      return false unless valid?

      request.save
      @well_request_join.save
      true
    end

    private

    def build_request(request_attributes)
      constants_accessor = Pipelines::ConstantsAccessor.new(Pipelines.ont.covid)
      sample = build_or_fetch_sample(request_attributes, constants_accessor)
      @request = ::Request.new(
        requestable: Ont::Request.new(
          external_study_id: constants_accessor.external_study_id
        ),
        sample: sample
      )
      @well_request_join = ::ContainerMaterial.new({ container: @well,
                                                     material: request.requestable })
    end

    def build_or_fetch_sample(request_attributes, constants_accessor)
      sample_attributes = request_attributes
                          .extract!(:name, :external_id)
                          .merge!(species: constants_accessor.species)
      Sample.find_or_initialize_by(sample_attributes)
    end

    def check_request
      if request.nil?
        errors.add('request', 'cannot be nil')
        return
      end

      return if request.valid?

      request.errors.each do |k, v|
        errors.add(k, v)
      end
    end
  end
end
