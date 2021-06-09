# frozen_string_literal: true

# Ont namespace
module Ont
  # PlateFactory
  # The factory will build a plate, associated wells and
  # requests from the request parameters
  class PlateFactory
    include ActiveModel::Model

    validate :check_plate, :check_well_factories

    #
    # Create a new PlateFactory ready to generate the nested information. Will
    # generate a plate, its wells and requests. In contrast to the PlateWithSamplesFactory
    # (which calls this) this will not actually perform the bulk insert
    #
    # @param attributes [Hash] Attributes hash
    # @option attributes [String] :barcode The barcode of the plate to generate
    # @option attributes [Array<Hash>] :wells Array of well attributes to use to generate wells
    #
    def initialize(attributes = {})
      build_requests(attributes)
    end

    attr_reader :plate

    def bulk_insert_serialise(bulk_insert_serialiser, **options)
      return false unless options[:validate] == false || valid?

      well_data = well_factories.map do |well_factory|
        well_factory.bulk_insert_serialise(bulk_insert_serialiser, validate: false)
      end
      bulk_insert_serialiser.plate_data(plate, well_data)
    end

    private

    attr_reader :well_factories

    def build_requests(attributes)
      wells_attributes = attributes.extract!(:wells)
      build_plate(attributes)
      tag_set_service = TagSetService.new
      @well_factories = (wells_attributes[:wells] || []).map do |well_attributes|
        WellFactory.new(plate: plate,
                        well_attributes: well_attributes,
                        tag_set_service: tag_set_service)
      end
    end

    def build_plate(attributes)
      plate_attributes = attributes.extract!(:barcode)
      @plate = ::Plate.new(plate_attributes)
    end

    def check_plate
      return if plate.valid?

      plate.errors.each do |k, v|
        errors.add(k, v)
      end
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
