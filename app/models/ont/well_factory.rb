# frozen_string_literal: true

# Ont namespace
module Ont
  # WellFactory
  # The factory will build a well and associated request
  # from the input attributes
  class WellFactory
    include ActiveModel::Model

    validate :check_well, :check_request_factories, :check_tag_service, :check_for_raised_exceptions

    def initialize(attributes = {})
      @request_factories = []
      @raised_exceptions = []
      return unless attributes.key?(:well_attributes)

      @plate = attributes[:plate]
      build_well(attributes[:well_attributes])
    end

    attr_reader :well

    def save
      return false unless valid?

      well.save
      @request_factories.collect(&:save)
      true
    end

    private

    def build_well(attributes)
      @well = ::Well.new(position: attributes[:position], plate: @plate)
      return unless attributes.key?(:samples)

      begin
        @tag_service = create_tag_service(attributes[:samples].count)
        @request_factories = attributes[:samples].map do |request_attributes|
          RequestFactory.new(well: well,
                             request_attributes: request_attributes,
                             tag_service: @tag_service)
        end
      rescue StandardError => e
        @raised_exceptions << e
      end
    end

    def create_tag_service(num_samples)
      case num_samples
      when 1
        nil
      when 96
        ::TagService.new(::TagSet.find_by!(name: 'OntWell96Samples'))
      when 384
        ::TagService.new(::TagSet.find_by!(name: 'OntWell384Samples'))
      else
        raise "'#{num_samples}' is not a supported number of samples"
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
      return if @request_factories.empty?

      @request_factories.each do |request_factory|
        next if request_factory.valid?

        request_factory.errors.each do |k, v|
          errors.add(k, v)
        end
      end
    end

    def check_tag_service
      return if @tag_service.nil?

      errors.add('samples', 'should all be uniquely tagged') unless @tag_service.complete?
    end

    def check_for_raised_exceptions
      return if @raised_exceptions.empty?

      @raised_exceptions.each do |ex|
        errors.add('exception raised:', ex.message)
      end
    end
  end
end
