# frozen_string_literal: true

# Ont namespace
module Ont
  # WellFactory
  # The factory will build a well and associated request
  # from the input attributes
  class WellFactory
    include ActiveModel::Model

    validate :check_well, :check_request_factory

    def initialize(attributes = {})
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
      request_factory&.save(validate: false)
      true
    end

    private

    attr_reader :request_factory

    def build_well(attributes)
      @well = ::Well.new(position: attributes[:position], plate: @plate)
      return unless attributes.key?(:sample)

      @request_factory = RequestFactory.new(well: well, request_attributes: attributes[:sample])
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

    def check_request_factory
      return if request_factory.nil? || request_factory.valid?

      request_factory.errors.each do |k, v|
        errors.add(k, v)
      end
    end
  end
end
