# frozen_string_literal: true

# Ont namespace
module Ont
  # PlateFactory
  # The factory will build a plate, associated wells and
  # requests from the request parameters
  class PlateFactory
    include ActiveModel::Model

    validate :check_well_factories

    def initialize(attributes = {})
      build_requests(attributes)
    end

    attr_reader :plate, :well_factories

    def save
      return false unless valid?

      plate.save
      well_factories.collect(&:save)
      true
    end

    private

    def build_requests(attributes)
      wells_with_samples_attributes = attributes.extract!(:wells)
      build_plate(attributes)
      @well_factories = (wells_with_samples_attributes[:wells] || []).map { |well_with_sample_attributes|
        WellFactory.new(plate: plate, well_with_sample_attributes: well_with_sample_attributes)
      }
    end

    def build_plate(attributes)
      plate_attributes = attributes.extract!(:barcode)
      @plate = ::Plate.new(plate_attributes)
    end

    def check_well_factories
      errors.add('wells', 'cannot be empty') if @well_factories.empty?

      well_factories.each do |well_factory|
        next if well_factory.valid?

        well_factory.errors.each do |k, v|
          errors.add(k, v)
        end
      end
    end
  end
end
