# frozen_string_literal: true

# Ont namespace
module Ont
  # WellFactory
  # The factory will build a well and associated request
  # from the input attributes
  class WellFactory
    include ActiveModel::Model

    validate :check_well, :check_request

    def initialize(attributes = {})
      @plate = attributes[:plate]
      return unless attributes.key?(:well_with_sample_attributes)

      build_well(attributes[:well_with_sample_attributes])
    end

    attr_reader :plate, :well, :request, :well_request_join

    def save
      return false unless valid?

      well.save
      request&.save
      well_request_join&.save
      true
    end

    private

    def build_well(attributes)
      @well = ::Well.new(position: attributes[:position], plate: plate)
      return unless attributes.key?(:sample)

      build_request(attributes[:sample])
      @well_request_join = ::ContainerMaterial.new({ container: well,
                                                     material: request.requestable })
    end

    def build_request(request_attributes)
      constants_accessor = Pipelines::ConstantsAccessor.new(Pipelines.ont.covid)
      sample = build_or_fetch_sample(request_attributes, constants_accessor)
      @request = ::Request.new(
        requestable: Ont::Request.new(
          external_study_id: constants_accessor.request_external_study_id
        ),
        sample: sample
      )
    end

    def build_or_fetch_sample(request_attributes, constants_accessor)
      sample_attributes = request_attributes
                          .extract!(:name, :external_id)
                          .merge!(species: constants_accessor.sample_species)
      Sample.find_or_initialize_by(sample_attributes)
    end

    def check_well
      if well.nil?
        errors.add('well', 'cannot be nil')
        return
      end

      return if well.valid?

      well.errors.each do |k, v|
        errors.add(k, v)
      end
    end

    def check_request
      return if request.nil? || request.valid?

      request.errors.each do |k, v|
        errors.add(k, v)
      end
    end
  end
end
