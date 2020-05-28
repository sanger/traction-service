# frozen_string_literal: true

# Ont namespace
module Ont
  # WellFactory
  # The factory will build a well and associated request
  # from the input attributes
  class WellFactory
    include ActiveModel::Model

    validate :check_well, :check_request_factories

    def initialize(attributes = {})
      return unless attributes.key?(:well_attributes)

      @plate = attributes[:plate]
      build_well(attributes[:well_attributes])
    end

    def bulk_insert_serialise(bulk_insert_serialiser, **options)
      return false unless options[:validate] == false || valid?

      # No need to validate any lower level objects since validation above has already checked them
      request_data = []
      unless request_factories.nil?
        request_data = request_factories.map do |request_factory|
          request_factory.bulk_insert_serialise(bulk_insert_serialiser, validate: false)
        end
      end

      bulk_insert_serialiser.well_data(well, request_data)
    end

    private

    attr_reader :plate, :well, :request_factories

    def build_well(attributes)
      @well = ::Well.new(position: attributes[:position], plate: @plate)
      return unless attributes.key?(:samples)

      @request_factories = attributes[:samples].map do |sample|
        RequestFactory.new(sample)
      end
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

    def check_request_factories
      return if request_factories.nil?

      request_factories.each do |request_factory|
        next if request_factory.valid?

        request_factory.errors.each do |k, v|
          errors.add(k, v)
        end
      end
    end
  end
end
