# frozen_string_literal: true

# Ont namespace
module Ont
  # WellFactory
  # The factory will build a well and associated request
  # from the input attributes
  class WellFactory
    include ActiveModel::Model

    validate :check_well, :check_request_factories, :check_for_raised_exceptions

    def initialize(attributes = {})
      @request_factories = []
      @raised_exceptions = []
      return unless attributes.key?(:well_attributes)

      @plate = attributes[:plate]
      build_well(attributes[:well_attributes])
    end

    attr_reader :well

    def save(**options)
      return false unless options[:validate] == false || valid?

      # No need to validate any lower level objects since validation above has already checked them
      well.save(validate: false)
      @request_factories.map { |request_factory| request_factory.save(validate: false) }
      true
    end

    private

    def build_well(attributes)
      @well = ::Well.new(position: attributes[:position], plate: @plate)
      return unless attributes.key?(:samples)

      begin
        validate_num_samples(attributes[:samples].count)
        @request_factories = attributes[:samples].map do |request_attributes|
          RequestFactory.new(well: well, request_attributes: request_attributes)
        end
      rescue StandardError => e
        @raised_exceptions << e
      end
    end

    def validate_num_samples(num_samples)
      raise "'#{num_samples}' is not a supported number of samples" unless num_samples == 1 
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
      return if @request_factories.empty?

      @request_factories.each do |request_factory|
        next if request_factory.valid?

        request_factory.errors.each do |k, v|
          errors.add(k, v)
        end
      end
    end

    def check_for_raised_exceptions
      return if @raised_exceptions.empty?

      @raised_exceptions.each do |ex|
        errors.add('exception raised:', ex.message)
      end
    end
  end
end
