# frozen_string_literal: true

# Ont namespace
module Ont
  # PlateWithSamplesFactory
  # A factory for bulk inserting a plate and all of its dependents
  class PlateWithSamplesFactory
    include ActiveModel::Model

    validate :check_plate_factory

    def initialize(attributes = {})
      @attributes = attributes
    end

    def process
      @plate_factory = Ont::PlateFactory.new(attributes)
    end

    def save(**options)
      return false unless options[:validate] == false || valid?

      @serialised_plate_data = plate_factory.bulk_insert_serialise(self, validate: false)
      bulk_insert
    end

    # Serialisation

    def ont_request_data(ont_request, tag_id)
      { ont_request: serialise_ont_request(ont_request), tag_id: tag_id }
    end

    def well_data(well, request_data)
      { well: serialise_well(well), request_data: request_data }
    end

    def plate_data(plate, well_data)
      { plate: serialise_plate(plate), well_data: well_data }
    end

    private

    attr_reader :attributes, :timestamps, :serialised_plate_data

    def timestamps
      time = DateTime.now
      @timestamps ||= { created_at: time, updated_at: time }
    end

    def serialise_ont_request(ont_request)
      {
        uuid: ont_request.uuid,
        external_id: ont_request.external_id,
        name: ont_request.name
      }.merge(timestamps)
    end

    def serialise_well(well)
      { position: well.position }.merge(timestamps)
    end

    def serialise_plate(plate)
      { barcode: plate.barcode }.merge(timestamps)
    end

    # Saving and Validation

    def check_plate_factory
      return if plate_factory.valid?

      plate_factory.errors.each do |k, v|
        errors.add(k, v)
      end
    end

    def bulk_insert
      # return the plate on success; otherwise false. Unsuccessful inserts should also generate errors
      ActiveRecord::Base.transaction do
        # insert plate (save)
        # update wells with plate id
        # insert wells
        # other things
        plate
      end
      false
    end
  end
end
