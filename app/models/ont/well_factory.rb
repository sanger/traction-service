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
      @plate = attributes[:plate]
      return unless attributes.key?(:well_attributes)

      build_well(attributes[:well_attributes])
    end

    attr_reader :plate, :well

    def request_factories
      @request_factories ||= []
    end

    def save
      return false unless valid?

      well.save
      request_factories.collect(&:save)
      true
    end

    private

    def build_well(attributes)
      @well = ::Well.new(position: attributes[:position], plate: plate)
      return unless attributes.key?(:samples)

      @request_factories = attributes[:samples].map do |request_attributes|
        RequestFactory.new(well: well, request_attributes: request_attributes)
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
      return if request_factories.empty?

      request_factories.each do |request_factory|
        next if request_factory.valid?

        request_factory.errors.each do |k, v|
          errors.add(k, v)
        end
      end
    end
  end
end
