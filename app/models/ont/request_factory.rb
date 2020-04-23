# frozen_string_literal: true

# Ont namespace
module Ont
  # RequestFactory
  # The factory will build a plate, associated wells and
  # requests from the request parameters
  class RequestFactory
    include ActiveModel::Model

    validate :check_plate_factory, :check_well_factories, :check_requests, :check_join_factories

    def initialize(attributes = {})
      build_requests(attributes)
    end

    attr_reader :plate_factory

    def well_factories
      @well_factories ||= []
    end

    def requests
      @requests ||= []
    end

    def join_factories
      @join_factories ||= []
    end

    def save
      return false unless valid?

      plate_factory.save
      well_factories.collect(&:save)
      requests.collect(&:save)
      join_factories.collect(&:save)
      true
    end

    private

    def build_requests(attributes)
      wells_with_samples_attributes = attributes.extract!(:wells)
      build_plate(attributes)
      wells_with_samples_attributes[:wells].each do |well_with_sample_attributes|
        build_well(well_with_sample_attributes)
        next unless well_with_sample_attributes.key?(:sample)

        build_request(well_with_sample_attributes[:sample])
        build_join
      end
    end

    def build_plate(attributes)
      @plate_factory = ::PlateFactory.new(attributes)
    end

    def build_well(well_with_sample_attributes)
      well_attributes = well_with_sample_attributes.merge(plate: plate_factory.plate)
      well_factories << ::WellFactory.new(well_attributes)
    end

    def build_request(request_attributes)
      sample = build_or_fetch_sample(request_attributes)
      requests << ::Request.new(
        requestable: Ont::Request.new(
          external_study_id: Pipelines.ont.covid.request.external_study_id),
        sample: sample
      )
    end

    def build_or_fetch_sample(request_attributes)
      sample_attributes = request_attributes
                          .extract!(:name, :external_id)
                          .merge!(species: Pipelines.ont.covid.sample.species)
      Sample.find_or_initialize_by(sample_attributes)
    end

    def build_join
      join_attributes = { container: well_factories.last.well, material: requests.last }
      join_factories << ::ContainerMaterialFactory.new(join_attributes)
    end

    def check_plate_factory
      return if plate_factory.valid?

      errors.concat(plate_factory.errors)
    end

    def check_well_factories
      errors.add('wells', 'there were no wells') if well_factories.empty?

      well_factories.each do |well_factory|
        next if well_factory.valid?

        errors.concat(well_factory.errors)
      end
    end

    def check_requests
      # Wells can be empty of samples, so don't fail on no requests
      requests.each do |request|
        next if request.valid?

        request.errors.each do |k, v|
          errors.add(k, v)
        end
      end
    end

    def check_join_factories
      # Wells can be empty of samples, so don't fail on no joins
      join_factories.each do |join_factory|
        next if join_factory.valid?

        errors.concat(join_factory.errors)
      end
    end
  end
end
